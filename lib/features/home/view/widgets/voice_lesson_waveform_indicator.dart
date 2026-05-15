import 'dart:math' as math;

import 'package:flutter/material.dart';

class VoiceLessonWaveformIndicator extends StatefulWidget {
  const VoiceLessonWaveformIndicator({super.key, required this.color});

  final Color color;

  @override
  State<VoiceLessonWaveformIndicator> createState() =>
      _VoiceLessonWaveformIndicatorState();
}

class _VoiceLessonWaveformIndicatorState
    extends State<VoiceLessonWaveformIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, _) {
        return Row(
          children: List.generate(4, (index) {
            final height =
                6.0 +
                10 *
                    (0.5 +
                        0.5 *
                            math.sin(_ctrl.value * 2 * math.pi + index * 0.8));
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              width: 3,
              height: height,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        );
      },
    );
  }
}
