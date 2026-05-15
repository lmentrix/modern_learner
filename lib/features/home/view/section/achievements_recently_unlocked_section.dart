import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/home/data/achievement_entity.dart';

class AchievementsRecentlyUnlockedSection extends StatelessWidget {
  const AchievementsRecentlyUnlockedSection({
    super.key,
    required this.achievements,
    required this.onTap,
  });

  final List<AchievementEntity> achievements;
  final void Function(AchievementEntity) onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: achievements.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final achievement = achievements[index];
          final tierColor = AchievementEntity.tierColor(
            achievement.currentLevel,
          );
          return GestureDetector(
            onTap: () => onTap(achievement),
            child: Container(
              width: 130,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    tierColor.withValues(alpha: 0.22),
                    AppColors.surfaceContainerLow,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: tierColor.withValues(alpha: 0.35)),
                boxShadow: [
                  BoxShadow(
                    color: tierColor.withValues(alpha: 0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: tierColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: tierColor.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      '${AchievementEntity.tierName(achievement.currentLevel).toUpperCase()} ${AchievementEntity.tierRoman(achievement.currentLevel)}',
                      style: GoogleFonts.inter(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: tierColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(achievement.emoji, style: const TextStyle(fontSize: 30)),
                  const SizedBox(height: 8),
                  Text(
                    achievement.title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                      height: 1.1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    achievement.subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppColors.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
