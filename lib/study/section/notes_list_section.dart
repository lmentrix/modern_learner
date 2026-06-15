import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/study/data/study_data.dart';
import 'package:modern_learner_production/study/model/study_models.dart';
import 'package:modern_learner_production/study/widgets/note_card.dart';
import 'package:modern_learner_production/theme/theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Section
// ─────────────────────────────────────────────────────────────────────────────

class NotesListSection extends StatefulWidget {
  const NotesListSection({
    super.key,
    required this.animate,
    required this.onNoteTap,
  });

  final bool animate;
  final ValueChanged<StudyNote> onNoteTap;

  @override
  State<NotesListSection> createState() => _NotesListSectionState();
}

class _NotesListSectionState extends State<NotesListSection> {
  late List<StudyNote> _notes;

  @override
  void initState() {
    super.initState();
    _notes = List.from(mockNotes);
  }

  void _deleteNote(String id) {
    setState(() => _notes.removeWhere((n) => n.id == id));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section header ──────────────────────────────────────────────
        Padding(
          padding: EduSpacing.pagePadding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Notes',
                    style: GoogleFonts.caveat(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  CustomPaint(
                    painter: _SectionUnderlinePainter(),
                    size: const Size(80, 6),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
                decoration: BoxDecoration(
                  color: EduColors.primaryLight,
                  borderRadius: BorderRadius.circular(7),
                  border: Border.all(
                    color: EduColors.primary.withValues(alpha: 0.30),
                    width: 1.2,
                  ),
                ),
                child: Text(
                  '${_notes.length} notes',
                  style: GoogleFonts.caveat(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: EduColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: EduSpacing.s4),

        // ── Note cards ──────────────────────────────────────────────────
        ...List.generate(_notes.length, (i) {
          final note = _notes[i];
          return _DeletableNoteCard(
            key: ValueKey(note.id),
            note: note,
            index: i,
            delay: Duration(milliseconds: widget.animate ? (100 * i + 80) : 0),
            animate: widget.animate,
            onTap: () => widget.onNoteTap(note),
            onDeleted: () => _deleteNote(note.id),
          );
        }),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Deletable wrapper with scribble-erase animation
// ─────────────────────────────────────────────────────────────────────────────

class _DeletableNoteCard extends StatefulWidget {
  const _DeletableNoteCard({
    super.key,
    required this.note,
    required this.index,
    required this.delay,
    required this.animate,
    required this.onTap,
    required this.onDeleted,
  });

  final StudyNote note;
  final int index;
  final Duration delay;
  final bool animate;
  final VoidCallback onTap;
  final VoidCallback onDeleted;

  @override
  State<_DeletableNoteCard> createState() => _DeletableNoteCardState();
}

class _DeletableNoteCardState extends State<_DeletableNoteCard>
    with TickerProviderStateMixin {
  // Entrance animation
  late final AnimationController _entranceCtrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  // Scribble-erase animation
  late final AnimationController _eraseCtrl;
  bool _erasing = false;
  bool _collapsed = false;

  @override
  void initState() {
    super.initState();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
      value: widget.animate ? 0.0 : 1.0,
    );
    _fade = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut));

    if (widget.animate) {
      Future.delayed(widget.delay, () {
        if (mounted) _entranceCtrl.forward();
      });
    }

    _eraseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
    );
    _eraseCtrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _collapsed = true);
        // Wait for AnimatedSize to finish collapsing before removing from list
        Future.delayed(const Duration(milliseconds: 320), () {
          if (mounted) widget.onDeleted();
        });
      }
    });
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _eraseCtrl.dispose();
    super.dispose();
  }

  void _onLongPress() {
    if (_erasing) return;
    HapticFeedback.heavyImpact();
    setState(() => _erasing = true);
    _eraseCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
      child: _collapsed
          ? const SizedBox(height: 0)
          : FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slide,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    EduSpacing.s6, 0, EduSpacing.s6, EduSpacing.s5,
                  ),
                  child: Stack(
                    children: [
                      NoteCard(
                        note: widget.note,
                        index: widget.index,
                        onTap: widget.onTap,
                        onLongPress: _onLongPress,
                      ),
                      // Scribble-erase overlay — only mounted while animating
                      if (_erasing)
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _eraseCtrl,
                            builder: (_, __) => ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: CustomPaint(
                                painter: _ScribbleErasePainter(
                                  phase: _eraseCtrl.value,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Scribble stroke data
// ─────────────────────────────────────────────────────────────────────────────

class _ScribbleStroke {
  const _ScribbleStroke({
    required this.p0,
    required this.pm,
    required this.p1,
    required this.thickness,
    required this.startPhase,
  });

  final Offset p0, pm, p1; // normalized 0..1 coordinates
  final double thickness;
  final double startPhase;  // raw phase (0..0.44) when this stroke starts appearing
}

// ─────────────────────────────────────────────────────────────────────────────
// CustomPainter — pencil scribble → eraser sweep → fade
// ─────────────────────────────────────────────────────────────────────────────

class _ScribbleErasePainter extends CustomPainter {
  const _ScribbleErasePainter({required this.phase});
  final double phase; // 0.0 → 1.0

  // Pre-generated strokes (static / deterministic)
  static final List<_ScribbleStroke> _strokes = _buildStrokes();
  static final List<Offset> _dustPoints = _buildDust();

  static List<_ScribbleStroke> _buildStrokes() {
    final rng = math.Random(42);
    final list = <_ScribbleStroke>[];

    // 10 long near-horizontal "crossing out" strokes, spread across card height
    for (int i = 0; i < 10; i++) {
      final cy = 0.07 + (i / 9.0) * 0.86 + (rng.nextDouble() - 0.5) * 0.05;
      final x0 = 0.01 + rng.nextDouble() * 0.06;
      final x1 = 0.93 + rng.nextDouble() * 0.06;
      list.add(_ScribbleStroke(
        p0: Offset(x0, cy),
        pm: Offset(
          0.45 + (rng.nextDouble() - 0.5) * 0.14,
          cy + (rng.nextDouble() - 0.5) * 0.07,
        ),
        p1: Offset(x1, cy + (rng.nextDouble() - 0.5) * 0.04),
        thickness: 1.8 + rng.nextDouble() * 1.6,
        startPhase: (i / 10.0) * 0.26,
      ));
    }

    // 15 short chaotic strokes scattered around
    for (int i = 0; i < 15; i++) {
      final cx = 0.08 + rng.nextDouble() * 0.84;
      final cy = 0.08 + rng.nextDouble() * 0.84;
      final len = 0.06 + rng.nextDouble() * 0.16;
      final angle = rng.nextDouble() * math.pi;
      list.add(_ScribbleStroke(
        p0: Offset(
          (cx - math.cos(angle) * len * 0.5).clamp(0.02, 0.97),
          (cy - math.sin(angle) * len * 0.5).clamp(0.02, 0.97),
        ),
        pm: Offset(
          cx + (rng.nextDouble() - 0.5) * 0.07,
          cy + (rng.nextDouble() - 0.5) * 0.07,
        ),
        p1: Offset(
          (cx + math.cos(angle) * len * 0.5).clamp(0.02, 0.97),
          (cy + math.sin(angle) * len * 0.5).clamp(0.02, 0.97),
        ),
        thickness: 1.2 + rng.nextDouble() * 2.1,
        startPhase: 0.08 + (i / 15.0) * 0.36,
      ));
    }

    list.sort((a, b) => a.startPhase.compareTo(b.startPhase));
    return list;
  }

  // Pre-generated eraser dust particle positions (normalized)
  static List<Offset> _buildDust() {
    final rng = math.Random(99);
    return List.generate(20, (_) => Offset(rng.nextDouble(), rng.nextDouble()));
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (phase <= 0.0) return;

    // ── Phase windows ─────────────────────────────────────────────────────
    // Scribble lines appear:  phase 0.00 → 0.44
    // Eraser sweeps right:    phase 0.38 → 0.76  (overlaps end of scribbling)
    // Fade-out overlay:       phase 0.74 → 1.00

    final eraserT = ((phase - 0.38) / 0.38).clamp(0.0, 1.0);
    final eraserX = eraserT * (size.width + 18); // slightly past right edge
    final fadeT   = ((phase - 0.74) / 0.26).clamp(0.0, 1.0);

    // ── 1. Pencil scribble strokes ────────────────────────────────────────
    final pencil = Paint()
      ..style    = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final s in _strokes) {
      // Skip strokes that haven't started yet
      if (phase < s.startPhase) continue;

      // Skip strokes whose midpoint the eraser has already swept past
      if (eraserT > 0 && s.pm.dx * size.width < eraserX - 8) continue;

      canvas.drawPath(
        Path()
          ..moveTo(s.p0.dx * size.width, s.p0.dy * size.height)
          ..quadraticBezierTo(
            s.pm.dx * size.width, s.pm.dy * size.height,
            s.p1.dx * size.width, s.p1.dy * size.height,
          ),
        pencil
          ..color       = const Color(0xFF1A1A2E).withValues(alpha: 0.80)
          ..strokeWidth = s.thickness,
      );
    }

    // ── 2. Eraser body — warm paper sweeping left-to-right ────────────────
    if (eraserT > 0) {
      final clampedX = eraserX.clamp(0.0, size.width);

      // Paper-colored fill (matches the note card's _paper color)
      canvas.drawRect(
        Rect.fromLTWH(0, 0, clampedX, size.height),
        Paint()..color = const Color(0xFFFEFCF5),
      );

      // Slightly rough eraser leading edge
      if (eraserX < size.width + 4) {
        canvas.drawLine(
          Offset(clampedX, 0),
          Offset(clampedX, size.height),
          Paint()
            ..color      = const Color(0xFFBFAF95).withValues(alpha: 0.45)
            ..strokeWidth = 2.8
            ..strokeCap  = StrokeCap.round,
        );

        // Eraser dust: small specks that trail just behind the leading edge
        for (final d in _dustPoints) {
          final px = clampedX - 2 - d.dx * 22;
          if (px < 0) continue;
          final alpha = (1.0 - d.dx) * 0.38;
          canvas.drawCircle(
            Offset(px, d.dy * size.height),
            0.5 + d.dy * 1.7,
            Paint()..color = const Color(0xFF94A3B8).withValues(alpha: alpha),
          );
        }
      }
    }

    // ── 3. Fade-out — paper-white overlay erases everything ───────────────
    if (fadeT > 0) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = const Color(0xFFFEFCF5).withValues(alpha: fadeT),
      );
    }
  }

  @override
  bool shouldRepaint(_ScribbleErasePainter old) => old.phase != phase;
}

// ── Wobbly underline beneath section title ───────────────────────────────────

class _SectionUnderlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.5)
        ..quadraticBezierTo(
            size.width * 0.40, size.height * 0.1,
            size.width * 0.75, size.height * 0.7)
        ..lineTo(size.width, size.height * 0.4),
      Paint()
        ..color       = EduColors.primary.withValues(alpha: 0.55)
        ..strokeWidth = 1.8
        ..style       = PaintingStyle.stroke
        ..strokeCap   = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_SectionUnderlinePainter old) => false;
}
