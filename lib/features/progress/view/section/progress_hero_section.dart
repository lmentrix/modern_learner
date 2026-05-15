import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/progress/data/progress_page_constants.dart';
import 'package:modern_learner_production/features/progress/data/progress_page_data.dart';

class ProgressHeroSection extends StatelessWidget {
  const ProgressHeroSection({super.key, required this.data});

  final ProgressPageData data;

  @override
  Widget build(BuildContext context) {
    final snapshot = data.snapshot;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: ProgressPageConstants.heroGradient,
        borderRadius: BorderRadius.circular(ProgressPageConstants.cardRadius),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 132,
            height: 132,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 132,
                  height: 132,
                  child: CircularProgressIndicator(
                    value: snapshot.completion,
                    strokeWidth: 12,
                    backgroundColor: AppColors.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      snapshot.accentColor,
                    ),
                  ),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: snapshot.completion),
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(value * 100).round()}%',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'overall',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(width: 22),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Learning momentum',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${snapshot.masteredLessons} of ${snapshot.totalLessons} lessons mastered so far.',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                _buildMetricRow(
                  label: 'Weekly goal',
                  value:
                      '${snapshot.weeklyMinutes}/${snapshot.weeklyGoalMinutes} min',
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: (snapshot.weeklyMinutes / snapshot.weeklyGoalMinutes)
                        .clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: AppColors.surfaceContainerHighest,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.tertiary,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _buildMetricRow(
                  label: 'Current focus',
                  value: snapshot.currentFocus,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow({required String label, required String value}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
