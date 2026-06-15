import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:modern_learner_production/voice/model/voice_models.dart';
import 'package:modern_learner_production/theme/theme.dart';

class WaveRingPainter extends CustomPainter {
  const WaveRingPainter({
    required this.phase,
    required this.state,
    required this.amplitude,
  });

  final double phase;     // 0.0 → 1.0 (looping animation value)
  final VoiceState state;
  final double amplitude; // 0.0 = minimal wobble, 1.0 = full wobble

  bool get _active =>
      state == VoiceState.recording || state == VoiceState.processing;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final int ringCount    = _active ? 5 : 3;
    final double baseR     = _active ? 52.0 : 58.0;
    final double spacing   = _active ? 22.0 : 26.0;
    final Color ringColor  = state == VoiceState.recording
        ? const Color(0xFFEF4444)
        : EduColors.primary;

    for (int i = 0; i < ringCount; i++) {
      // Phase offset so each ring expands at a different moment
      final ringPhase = (phase + i / ringCount) % 1.0;

      // Radius grows slightly as the ring expands outward
      final r = baseR + i * spacing + ringPhase * spacing * 0.4;

      // Opacity fades as the ring expands
      final rawOpacity = _active
          ? (1.0 - ringPhase) * (0.55 - i * 0.07)
          : (1.0 - ringPhase * 0.25) * (0.22 - i * 0.05);
      final opacity = rawOpacity.clamp(0.0, 1.0);
      if (opacity <= 0.01) continue;

      final strokeW = _active
          ? (2.2 - i * 0.25).clamp(1.0, 2.2)
          : (1.4 - i * 0.1).clamp(0.9, 1.4);

      canvas.drawPath(
        _wobblyCircle(center, r, seed: i * 7, amplitude: amplitude),
        Paint()
          ..color = ringColor.withValues(alpha: opacity)
          ..strokeWidth = strokeW
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }

    // Processing: extra rotating arc overlay
    if (state == VoiceState.processing) {
      final arcPaint = Paint()
        ..color = EduColors.star.withValues(alpha: 0.55)
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: baseR + 8),
        phase * 2 * math.pi,
        math.pi * 0.65,
        false,
        arcPaint,
      );
    }
  }

  /// Builds a slightly wobbly closed circle path using sin-wave radius displacement,
  /// giving the hand-drawn sketch feel.
  Path _wobblyCircle(Offset center, double radius,
      {required int seed, required double amplitude}) {
    const points = 72;
    final wobbleScale = amplitude * 3.5 + 1.8;
    final s = seed * 1.37;
    final path = Path();
    for (int i = 0; i <= points; i++) {
      final t = i / points;
      final angle = t * 2 * math.pi;
      final wobble = wobbleScale *
          (math.sin(angle * 2.5 + s * 0.3) * 0.55 +
              math.sin(angle * 4.1 + s * 1.1) * 0.30 +
              math.sin(angle * 7.3 + s * 2.7) * 0.15);
      final r = radius + wobble;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(WaveRingPainter old) =>
      old.phase != phase || old.state != state || old.amplitude != amplitude;
}
