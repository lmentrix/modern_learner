import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/home/data/achievement_entity.dart';

class AchievementDetailStatusSection extends StatelessWidget {
  const AchievementDetailStatusSection({super.key, required this.achievement});

  final AchievementEntity achievement;

  @override
  Widget build(BuildContext context) {
    final isLocked = achievement.isLocked;
    final tierColor = isLocked
        ? AppColors.onSurfaceVariant
        : AchievementEntity.tierColor(achievement.currentLevel);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLocked
              ? AppColors.outlineVariant.withValues(alpha: 0.12)
              : tierColor.withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isLocked
                  ? AppColors.surfaceContainerHighest
                  : tierColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              isLocked ? Icons.lock_rounded : Icons.emoji_events_rounded,
              color: isLocked
                  ? AppColors.onSurfaceVariant.withValues(alpha: 0.55)
                  : tierColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLocked
                      ? 'Not Started'
                      : achievement.isMaxLevel
                      ? 'Fully Mastered! 🎉'
                      : '${AchievementEntity.tierName(achievement.currentLevel)} '
                            '${AchievementEntity.tierRoman(achievement.currentLevel)} Earned',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isLocked ? AppColors.onSurfaceVariant : tierColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isLocked
                      ? 'Start learning to earn your first level!'
                      : achievement.isMaxLevel
                      ? 'You\'ve reached the Diamond tier. Legendary!'
                      : 'Keep going to reach '
                            '${AchievementEntity.tierName(achievement.currentLevel + 1)} '
                            '${AchievementEntity.tierRoman(achievement.currentLevel + 1)}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
