import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/progress/data/progress_page_constants.dart';
import 'package:modern_learner_production/features/progress/data/progress_week_day.dart';

class ProgressWeekBar extends StatelessWidget {
  const ProgressWeekBar({
    super.key,
    required this.day,
    required this.accentColor,
    this.isSelected = false,
    this.onTap,
  });

  final ProgressWeekDay day;
  final Color accentColor;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ratio = (day.minutes / day.goalMinutes).clamp(0.08, 1.0);
    final isActive = day.minutes > 0;
    final highlight = isSelected || day.isToday;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
        decoration: isSelected
            ? BoxDecoration(
                color: accentColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // minute count above bar
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: highlight
                    ? accentColor
                    : AppColors.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              child: Text(day.minutes > 0 ? '${day.minutes}' : ''),
            ),
            const SizedBox(height: 4),
            SizedBox(
              height: ProgressPageConstants.barChartHeight,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: ratio),
                  duration: const Duration(milliseconds: 750),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    final barHeight =
                        34 + (ProgressPageConstants.barChartHeight - 34) * value;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isSelected ? 30 : 26,
                      height: barHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: isActive
                              ? [
                                  accentColor,
                                  accentColor.withValues(
                                    alpha: isSelected ? 0.65 : 0.42,
                                  ),
                                ]
                              : [
                                  AppColors.surfaceContainerHighest,
                                  AppColors.surfaceContainerHighest,
                                ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: highlight
                            ? Border.all(
                                color: accentColor.withValues(alpha: 0.55),
                                width: 1.5,
                              )
                            : null,
                        boxShadow: highlight && isActive
                            ? [
                                BoxShadow(
                                  color: accentColor.withValues(alpha: 0.35),
                                  blurRadius: isSelected ? 24 : 16,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              day.label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: highlight ? FontWeight.w800 : FontWeight.w500,
                color: highlight ? accentColor : AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: highlight
                    ? accentColor
                    : Colors.transparent,
                shape: BoxShape.circle,
                boxShadow: highlight
                    ? [
                        BoxShadow(
                          color: accentColor.withValues(alpha: 0.6),
                          blurRadius: 4,
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
