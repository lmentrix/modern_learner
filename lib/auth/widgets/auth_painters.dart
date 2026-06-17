import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:modern_learner_production/theme/theme.dart';

class LogoRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    const r1 = 40.0;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r1),
      -math.pi * 0.55,
      math.pi * 1.82,
      false,
      Paint()
        ..color = EduColors.primary.withValues(alpha: 0.35)
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx + 0.6, cy - 0.6), radius: r1 - 2),
      math.pi * 0.84,
      math.pi * 0.54,
      false,
      Paint()
        ..color = EduColors.primary.withValues(alpha: 0.14)
        ..strokeWidth = 1.3
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx - 0.4, cy + 0.4), radius: r1 - 5),
      -math.pi * 0.20,
      math.pi * 1.30,
      false,
      Paint()
        ..color = EduColors.primary.withValues(alpha: 0.10)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Decorative star at top-right of ring
    const cx2 = 68.0;
    const cy2 = 14.0;
    const r = 4.0;
    const inner = r * 0.42;
    final star = Path();
    for (var i = 0; i < 5; i++) {
      final oa = -math.pi / 2 + i * 2 * math.pi / 5;
      final ia = oa + math.pi / 5;
      final px = cx2 + r * math.cos(oa);
      final py = cy2 + r * math.sin(oa);
      final ix = cx2 + inner * math.cos(ia);
      final iy = cy2 + inner * math.sin(ia);
      i == 0 ? star.moveTo(px, py) : star.lineTo(px, py);
      star.lineTo(ix, iy);
    }
    star.close();
    canvas.drawPath(
      star,
      Paint()
        ..color = const Color(0xFFF59E0B).withValues(alpha: 0.80)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(LogoRingPainter old) => false;
}

class TitleUnderlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = EduColors.primary.withValues(alpha: 0.55)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(
      Path()
        ..moveTo(0, size.height * 0.55)
        ..quadraticBezierTo(
          size.width * 0.30,
          size.height * 0.05,
          size.width * 0.65,
          size.height * 0.78,
        )
        ..lineTo(size.width, size.height * 0.30),
      p,
    );
    canvas.drawPath(
      Path()
        ..moveTo(1.5, size.height * 0.95)
        ..quadraticBezierTo(
          size.width * 0.38,
          size.height * 0.45,
          size.width * 0.70,
          size.height * 1.0,
        )
        ..lineTo(size.width, size.height * 0.65),
      p
        ..color = EduColors.primary.withValues(alpha: 0.18)
        ..strokeWidth = 1.4,
    );
  }

  @override
  bool shouldRepaint(TitleUnderlinePainter old) => false;
}
