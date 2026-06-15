import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/theme/theme.dart';

class VoiceHeaderSection extends StatelessWidget {
  const VoiceHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EduSpacing.pagePadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Voice Notes',
                    style: GoogleFonts.caveat(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: EduColors.textPrimary,
                      height: 1.1,
                    ),
                  ),
                  CustomPaint(
                    painter: _TitleUnderlinePainter(),
                    size: const Size(152, 9),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: EduColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: EduColors.shadowCard,
                ),
                child: const Icon(Icons.history_rounded,
                    size: 20, color: EduColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: EduSpacing.s2),
          Text(
            'Speak to capture your ideas instantly',
            style: GoogleFonts.caveat(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: EduColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _TitleUnderlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Wavy underline
    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.55)
        ..quadraticBezierTo(
          size.width * 0.25, size.height * 0.05,
          size.width * 0.52, size.height * 0.70,
        )
        ..quadraticBezierTo(
          size.width * 0.75, size.height * 1.20,
          size.width * 0.95, size.height * 0.35,
        ),
      Paint()
        ..color = EduColors.primary.withValues(alpha: 0.45)
        ..strokeWidth = 2.1
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    // Star accent to the right of the underline
    _drawStar(canvas, Offset(size.width + 10, size.height * 0.1), 4.5);
  }

  void _drawStar(Canvas canvas, Offset center, double r) {
    final paint = Paint()
      ..color = EduColors.star.withValues(alpha: 0.72)
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 4; i++) {
      final angle = i * math.pi / 4;
      canvas.drawLine(
        Offset(center.dx + math.cos(angle) * r * 0.32,
            center.dy + math.sin(angle) * r * 0.32),
        Offset(center.dx + math.cos(angle) * r,
            center.dy + math.sin(angle) * r),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_TitleUnderlinePainter old) => false;
}
