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
  });

  final ProgressWeekDay day;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final ratio = (day.minutes / day.goalMinutes).clamp(0.08, 1.0);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: ProgressPageConstants.barChartHeight,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: ratio),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Container(
                  width: 28,
                  height:
                      34 + (ProgressPageConstants.barChartHeight - 34) * value,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        accentColor,
                        accentColor.withValues(alpha: 0.42),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: day.isToday
                        ? [
                            BoxShadow(
                              color: accentColor.withValues(alpha: 0.24),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ]
                        : null,
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          day.label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: day.isToday ? FontWeight.w700 : FontWeight.w500,
            color: day.isToday
                ? AppColors.onSurface
                : AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${day.minutes}',
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppColors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
