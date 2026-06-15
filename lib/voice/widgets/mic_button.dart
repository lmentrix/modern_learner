import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:modern_learner_production/voice/model/voice_models.dart';
import 'package:modern_learner_production/theme/theme.dart';

class MicButton extends StatefulWidget {
  const MicButton({
    super.key,
    required this.state,
    required this.onTap,
  });

  final VoiceState state;
  final VoidCallback onTap;

  @override
  State<MicButton> createState() => _MicButtonState();
}

class _MicButtonState extends State<MicButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 110),
      value: 1.0,
    );
    _scale = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) => _ctrl.reverse();
  void _onTapUp(_) {
    _ctrl.forward();
    widget.onTap();
  }
  void _onTapCancel() => _ctrl.forward();

  @override
  Widget build(BuildContext context) {
    final isRecording   = widget.state == VoiceState.recording;
    final isProcessing  = widget.state == VoiceState.processing;

    final Color inkColor = isRecording
        ? const Color(0xFFEF4444)
        : isProcessing
            ? EduColors.star
            : EduColors.primary;

    final IconData icon = isRecording
        ? Icons.stop_rounded
        : isProcessing
            ? Icons.hourglass_bottom_rounded
            : Icons.mic_rounded;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scale,
        child: CustomPaint(
          painter: _MicRingPainter(color: inkColor),
          child: SizedBox(
            width: 88,
            height: 88,
            child: Center(
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: inkColor,
                  boxShadow: [
                    BoxShadow(
                      color: inkColor.withValues(alpha: 0.38),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(icon, size: 32, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Hand-drawn imperfect ring around the mic button
class _MicRingPainter extends CustomPainter {
  const _MicRingPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: 43),
      -math.pi * 0.60,
      math.pi * 1.85,
      false,
      Paint()
        ..color = color.withValues(alpha: 0.28)
        ..strokeWidth = 1.6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    // Gap arc for hand-drawn feel
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx + 0.6, cy - 0.6), radius: 41.5),
      math.pi * 0.78,
      math.pi * 0.58,
      false,
      Paint()
        ..color = color.withValues(alpha: 0.12)
        ..strokeWidth = 1.1
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_MicRingPainter old) => old.color != color;
}
