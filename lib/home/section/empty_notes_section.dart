import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/home/widgets/empty_notes_illustration.dart';
import 'package:modern_learner_production/theme/theme.dart';

class EmptyNotesSection extends StatelessWidget {
  const EmptyNotesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: EduSpacing.s6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'My notes',
                style: GoogleFonts.caveat(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: EduColors.textPrimary,
                ),
              ),
              CustomPaint(
                painter: _ThinAccentLine(),
                size: const Size(70, 5),
              ),
            ],
          ),
          const SizedBox(height: EduSpacing.s8),
          const Center(child: EmptyNotesIllustration()),
        ],
      ),
    );
  }
}

class _ThinAccentLine extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.6)
        ..quadraticBezierTo(
            size.width * 0.30, size.height * 0.1,
            size.width * 0.62, size.height * 0.7)
        ..lineTo(size.width * 0.90, size.height * 0.3),
      Paint()
        ..color = EduColors.primary.withValues(alpha: 0.40)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ThinAccentLine old) => false;
}
