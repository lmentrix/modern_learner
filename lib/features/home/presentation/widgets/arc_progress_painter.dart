import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';

class ArcProgressPainter extends CustomPainter {
  const ArcProgressPainter({required this.progress, required this.animation})
      : super(repaint: animation);

  final double progress;
  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    const startAngle = -math.pi * 0.75;
    const sweepFull = math.pi * 1.5;

    // Track
    final trackPaint = Paint()
      ..color = AppColors.surfaceContainerHigh
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepFull,
      false,
      trackPaint,
    );

    // Glow behind progress arc
    final glowPaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.primaryDim, AppColors.primary],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepFull * animation.value * progress,
      false,
      glowPaint,
    );

    // Crisp progress arc on top
    final progressPaint = Paint()
      ..shader = const LinearGradient(
        colors: [AppColors.primaryDim, AppColors.primary],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepFull * animation.value * progress,
      false,
      progressPaint,
    );

    // Dot at tip
    final tipAngle =
        startAngle + sweepFull * animation.value * progress;
    final tipX = center.dx + radius * math.cos(tipAngle);
    final tipY = center.dy + radius * math.sin(tipAngle);
    final dotPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(tipX, tipY), 6, dotPaint);
  }

  @override
  bool shouldRepaint(ArcProgressPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
