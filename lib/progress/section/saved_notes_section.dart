import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/progress/data/progress_data.dart';
import 'package:modern_learner_production/progress/widget/saved_note_tile.dart';
import 'package:modern_learner_production/theme/theme.dart';

class SavedNotesSection extends StatefulWidget {
  const SavedNotesSection({super.key, required this.animate});

  final bool animate;

  @override
  State<SavedNotesSection> createState() => _SavedNotesSectionState();
}

class _SavedNotesSectionState extends State<SavedNotesSection>
    with TickerProviderStateMixin {
  late final List<AnimationController> _ctrls;
  late final List<Animation<double>> _fades;
  late final List<Animation<Offset>> _slides;

  @override
  void initState() {
    super.initState();
    _ctrls = List.generate(
      savedNotes.length,
      (_) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 380),
      ),
    );
    _fades = _ctrls
        .map((c) => CurvedAnimation(parent: c, curve: Curves.easeOut))
        .toList();
    _slides = _ctrls
        .map((c) => Tween<Offset>(begin: const Offset(0, 0.07), end: Offset.zero)
            .animate(CurvedAnimation(parent: c, curve: Curves.easeOut)))
        .toList();
    if (widget.animate) _stagger();
  }

  void _stagger() {
    for (var i = 0; i < _ctrls.length; i++) {
      Future.delayed(Duration(milliseconds: 100 * i), () {
        if (mounted) _ctrls[i].forward();
      });
    }
  }

  @override
  void didUpdateWidget(SavedNotesSection old) {
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
        Padding(
          padding: EduSpacing.pagePadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Saved Notes',
                    style: GoogleFonts.caveat(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: EduColors.textPrimary,
                    ),
                  ),
                  CustomPaint(
                    painter: _SketchAccentLine(width: 90),
                    size: const Size(90, 5),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {},
                child: Text(
                  'View all',
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
        ...List.generate(savedNotes.length, (i) {
          return FadeTransition(
            opacity: _fades[i],
            child: SlideTransition(
              position: _slides[i],
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  EduSpacing.s6, 0, EduSpacing.s6, EduSpacing.s4,
                ),
                child: SavedNoteTile(ref: savedNotes[i]),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _SketchAccentLine extends CustomPainter {
  const _SketchAccentLine({required this.width});
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.6)
        ..quadraticBezierTo(
            width * 0.30, size.height * 0.1,
            width * 0.62, size.height * 0.7)
        ..lineTo(width * 0.90, size.height * 0.3),
      Paint()
        ..color = EduColors.primary.withValues(alpha: 0.40)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_SketchAccentLine old) => false;
}
