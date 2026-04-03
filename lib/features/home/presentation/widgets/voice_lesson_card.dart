import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';

class VoiceLessonCard extends StatefulWidget {
  const VoiceLessonCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.accentColor,
    required this.emoji,
    this.isActive = false,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final String duration;
  final Color accentColor;
  final String emoji;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  State<VoiceLessonCard> createState() => _VoiceLessonCardState();
}

class _VoiceLessonCardState extends State<VoiceLessonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    if (widget.isActive) _pulse.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: AnimatedBuilder(
            animation: _pulse,
            builder: (context, child) {
              return Container(
                width: 180,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                  border: Border(
                    top: BorderSide(
                      color:
                          AppColors.outlineVariant.withValues(alpha: 0.20),
                      width: 0.5,
                    ),
                    left: BorderSide(
                      color:
                          AppColors.outlineVariant.withValues(alpha: 0.20),
                      width: 0.5,
                    ),
                  ),
                  boxShadow: widget.isActive
                      ? [
                          BoxShadow(
                            color: widget.accentColor
                                .withValues(alpha: 0.12 + _pulse.value * 0.12),
                            blurRadius: 24 + _pulse.value * 12,
                            spreadRadius: 0,
                          ),
                        ]
                      : null,
                ),
                padding: const EdgeInsets.all(16),
                child: child,
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Waveform + emoji
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: widget.accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(widget.emoji,
                            style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                    const Spacer(),
                    if (widget.isActive)
                      _WaveformIndicator(color: widget.accentColor),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  widget.title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        widget.duration,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: widget.accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WaveformIndicator extends StatefulWidget {
  const _WaveformIndicator({required this.color});
  final Color color;

  @override
  State<_WaveformIndicator> createState() => _WaveformIndicatorState();
}

class _WaveformIndicatorState extends State<_WaveformIndicator>
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
          children: List.generate(4, (i) {
            final h = 6.0 +
                10 *
                    (0.5 +
                        0.5 *
                            math.sin(
                                _ctrl.value * 2 * math.pi + i * 0.8));
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              width: 3,
              height: h,
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
