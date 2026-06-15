import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/study/model/study_models.dart';
import 'package:modern_learner_production/study/section/note_reader_section.dart';
import 'package:modern_learner_production/study/section/notes_list_section.dart';
import 'package:modern_learner_production/theme/theme.dart';

class StudyPage extends StatefulWidget {
  const StudyPage({super.key});

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> with TickerProviderStateMixin {
  static const _sectionCount = 2;
  static const _staggerMs    = 120;
  static const _durationMs   = 420;

  late final List<AnimationController> _entranceCtrls;
  late final List<Animation<double>> _fades;
  late final List<Animation<Offset>> _slides;
  final List<bool> _started = List.filled(_sectionCount, false);

  StudyNote? _openNote;
  int _selectedFilter = 0;

  static const _filters = ['All', 'ML', 'Philosophy', 'Biology'];

  @override
  void initState() {
    super.initState();
    _entranceCtrls = List.generate(
      _sectionCount,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: _durationMs),
      ),
    );
    _fades = _entranceCtrls
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();
    _slides = _entranceCtrls
        .map((c) => Tween<Offset>(
              begin: const Offset(0, 0.06),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: c, curve: Curves.easeOut)))
        .toList();
    _launchEntrance();
  }

  void _launchEntrance() {
    for (var i = 0; i < _sectionCount; i++) {
      Future.delayed(Duration(milliseconds: _staggerMs * i), () {
        if (!mounted) return;
        setState(() => _started[i] = true);
        _entranceCtrls[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _entranceCtrls) { c.dispose(); }
    super.dispose();
  }

  Widget _wrap(int i, Widget child) => FadeTransition(
        opacity: _fades[i],
        child: SlideTransition(position: _slides[i], child: child),
      );

  @override
  Widget build(BuildContext context) {
    if (_openNote != null) {
      return NoteReaderSection(
        note: _openNote!,
        onClose: () => setState(() => _openNote = null),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Sketch header ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _wrap(
              0,
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    EduSpacing.s6, EduSpacing.s5, EduSpacing.s6, EduSpacing.s4,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Hand-stamp title
                              CustomPaint(
                                painter: _StudyHeaderPainter(),
                                size: const Size(140, 42),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Pick up where you left off.',
                                style: GoogleFonts.caveat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: EduColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          // Sketch search button
                          _SketchIconButton(
                            icon: Icons.search_rounded,
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: EduSpacing.s5),

                      // ── Sketch filter tabs ─────────────────────────────
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _filters.asMap().entries.map((e) {
                            return Padding(
                              padding: EdgeInsets.only(
                                  right: e.key < _filters.length - 1
                                      ? EduSpacing.s2
                                      : 0),
                              child: _SketchFilterChip(
                                label:    e.value,
                                selected: e.key == _selectedFilter,
                                index:    e.key,
                                onTap:    () => setState(() => _selectedFilter = e.key),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: EduSpacing.s2)),

          SliverToBoxAdapter(
            child: _wrap(
              1,
              NotesListSection(
                animate: _started[1],
                onNoteTap: (note) => setState(() => _openNote = note),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sketch icon button (search, etc.)
// ─────────────────────────────────────────────────────────────────────────────

class _SketchIconButton extends StatelessWidget {
  const _SketchIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _SketchCircleButtonPainter(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon,
              color: const Color(0xFF1A1A2E).withValues(alpha: 0.80), size: 22),
        ),
      ),
    );
  }
}

class _SketchCircleButtonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width  / 2;
    final cy = size.height / 2;
    const r  = 20.0;

    canvas.drawCircle(Offset(cx, cy), r,
        Paint()..color = const Color(0xFFFEFCF5));

    // Sketch circle border (two passes)
    canvas.drawCircle(Offset(cx, cy), r,
        Paint()
          ..color = const Color(0xFF1A1A2E).withValues(alpha: 0.58)
          ..strokeWidth = 1.6
          ..style = PaintingStyle.stroke);
    canvas.drawCircle(Offset(cx + 0.8, cy + 1.0), r - 2,
        Paint()
          ..color = const Color(0xFF1A1A2E).withValues(alpha: 0.12)
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke);
  }

  @override
  bool shouldRepaint(_SketchCircleButtonPainter old) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Sketch filter chip
// ─────────────────────────────────────────────────────────────────────────────

class _SketchFilterChip extends StatelessWidget {
  const _SketchFilterChip({
    required this.label,
    required this.selected,
    required this.index,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final int index;
  final VoidCallback onTap;

  static const _tilts = [0.015, -0.010, 0.012, -0.008];

  @override
  Widget build(BuildContext context) {
    final tilt = _tilts[index % _tilts.length];

    return GestureDetector(
      onTap: onTap,
      child: Transform.rotate(
        angle: tilt,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? EduColors.primary
                : const Color(0xFFFEFCF5),
            borderRadius: BorderRadius.circular(9),
            border: Border.all(
              color: selected
                  ? EduColors.primary
                  : const Color(0xFF1A1A2E).withValues(alpha: 0.38),
              width: selected ? 1.8 : 1.4,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: EduColors.primary.withValues(alpha: 0.28),
                      blurRadius: 8,
                      offset: const Offset(1, 3),
                    )
                  ]
                : [
                    BoxShadow(
                      color: const Color(0xFF1A1A2E).withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(1, 2),
                    )
                  ],
          ),
          child: Text(
            label,
            style: GoogleFonts.caveat(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : const Color(0xFF1A1A2E),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CustomPainter — "Study" header title with wobbly underline
// ─────────────────────────────────────────────────────────────────────────────

class _StudyHeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final tp = TextPainter(
      text: TextSpan(
        text: 'Study  ✏',
        style: GoogleFonts.caveat(
          fontSize: 30,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1A1A2E),
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset.zero);

    // Wobbly underline
    final ul = Paint()
      ..color = EduColors.primary.withValues(alpha: 0.72)
      ..strokeWidth = 2.3
      ..strokeCap = StrokeCap.round;

    const y  = 37.0;
    const w  = 100.0;
    canvas.drawPath(
      Path()
        ..moveTo(0, y)
        ..quadraticBezierTo(w * 0.30, y + 2.2, w * 0.65, y - 1.0)
        ..lineTo(w, y + 0.6),
      ul,
    );
    canvas.drawPath(
      Path()
        ..moveTo(1.5, y + 2.5)
        ..quadraticBezierTo(w * 0.38, y + 4.0, w * 0.70, y + 1.8)
        ..lineTo(w, y + 3.0),
      ul..color = EduColors.primary.withValues(alpha: 0.18) ..strokeWidth = 1.3,
    );
  }

  @override
  bool shouldRepaint(_StudyHeaderPainter old) => false;
}
