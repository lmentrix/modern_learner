import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/home/data/achievement_entity.dart';

class AchievementDetailLevelProgressionSection extends StatelessWidget {
  const AchievementDetailLevelProgressionSection({
    super.key,
    required this.achievement,
  });

  final AchievementEntity achievement;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LEVEL PROGRESSION',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(5, (i) {
            final levelNum = i + 1;
            final isEarned = levelNum <= achievement.currentLevel;
            final isCurrent = levelNum == achievement.currentLevel;
            final isNext = levelNum == achievement.currentLevel + 1;
            final tierColor = AchievementEntity.tierColor(levelNum);
            final tierName = AchievementEntity.tierName(levelNum);
            final tierRoman = AchievementEntity.tierRoman(levelNum);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isEarned
                          ? tierColor.withValues(alpha: 0.18)
                          : AppColors.surfaceContainerHighest,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isEarned
                            ? tierColor.withValues(alpha: 0.50)
                            : AppColors.outlineVariant.withValues(alpha: 0.20),
                        width: isCurrent ? 2.0 : 1.0,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        tierRoman,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isEarned
                              ? tierColor
                              : AppColors.onSurfaceVariant.withValues(
                                  alpha: 0.35,
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '$tierName $tierRoman',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isEarned
                                    ? AppColors.onSurface
                                    : AppColors.onSurfaceVariant.withValues(
                                        alpha: 0.45,
                                      ),
                              ),
                            ),
                            if (isCurrent) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: tierColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'CURRENT',
                                  style: GoogleFonts.inter(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w800,
                                    color: tierColor,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          achievement.levelRequirements[i],
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: isEarned
                                ? AppColors.onSurfaceVariant
                                : AppColors.onSurfaceVariant.withValues(
                                    alpha: 0.35,
                                  ),
                          ),
                        ),
                        if (isNext && !achievement.isMaxLevel) ...[
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: achievement.progressToNextLevel,
                              minHeight: 4,
                              backgroundColor: tierColor.withValues(
                                alpha: 0.14,
                              ),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                tierColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${(achievement.progressToNextLevel * 100).toStringAsFixed(0)}% to $tierName $tierRoman',
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: tierColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (isEarned)
                    Icon(Icons.check_circle_rounded, color: tierColor, size: 18)
                  else
                    Icon(
                      Icons.radio_button_unchecked_rounded,
                      color: AppColors.outlineVariant.withValues(alpha: 0.30),
                      size: 18,
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
