import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/study/data/study_data.dart';
import 'package:modern_learner_production/study/model/study_models.dart';
import 'package:modern_learner_production/study/widgets/note_card.dart';
import 'package:modern_learner_production/theme/theme.dart';

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

class _NotesListSectionState extends State<NotesListSection>
    with TickerProviderStateMixin {
  late final List<AnimationController> _ctrls;
  late final List<Animation<double>> _fades;
  late final List<Animation<Offset>> _slides;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(
      mockNotes.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 420),
      ),
    );
    _fades = _ctrls
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();
    _slides = _ctrls
        .map((c) => Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeOut)))
        .toList();

    if (widget.animate) _stagger();
  }

  void _stagger() {
    for (var i = 0; i < _ctrls.length; i++) {
      Future.delayed(Duration(milliseconds: 100 * i + 80), () {
        if (mounted) _ctrls[i].forward();
      });
    }
  }

  @override
  void didUpdateWidget(NotesListSection old) {
    super.didUpdateWidget(old);
    if (!old.animate && widget.animate) _stagger();
  }

  @override
  void dispose() {
    for (final c in _ctrls) { c.dispose(); }
    super.dispose();
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
                  // Hand-drawn underline
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
                  '${mockNotes.length} notes',
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
        ...List.generate(mockNotes.length, (i) {
          final note = mockNotes[i];
          return FadeTransition(
            opacity: _fades[i],
            child: SlideTransition(
              position: _slides[i],
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  EduSpacing.s6, 0, EduSpacing.s6, EduSpacing.s5,
                ),
                child: NoteCard(
                  note:  note,
                  index: i,
                  onTap: () => widget.onNoteTap(note),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
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
        ..color = EduColors.primary.withValues(alpha: 0.55)
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_SectionUnderlinePainter old) => false;
}
