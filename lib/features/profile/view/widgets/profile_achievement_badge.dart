import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/home/data/achievement_entity.dart';

class ProfileAchievementBadge extends StatelessWidget {
  const ProfileAchievementBadge({super.key, required this.achievement});

  final AchievementEntity achievement;

  @override
  Widget build(BuildContext context) {
    final isLocked = achievement.isLocked;
    final tierColor = isLocked
        ? AppColors.onSurfaceVariant
        : AchievementEntity.tierColor(achievement.currentLevel);

    return Container(
      width: 124,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isLocked ? AppColors.surfaceContainerLow : null,
        gradient: isLocked
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  tierColor.withValues(alpha: 0.22),
                  AppColors.surfaceContainerLow,
                ],
              ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: tierColor.withValues(alpha: isLocked ? 0.18 : 0.35),
          width: isLocked ? 1 : 1.5,
        ),
        boxShadow: isLocked
            ? null
            : [
                BoxShadow(
                  color: tierColor.withValues(alpha: 0.16),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: tierColor.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Icon(
                isLocked ? Icons.lock_rounded : _iconFor(achievement),
                size: 26,
                color: tierColor,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Center(
              child: Text(
                achievement.title,
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: isLocked
                      ? AppColors.onSurfaceVariant
                      : AppColors.onSurface,
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: tierColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              isLocked
                  ? 'Unavailable'
                  : '${AchievementEntity.tierName(achievement.currentLevel)} '
                        '${AchievementEntity.tierRoman(achievement.currentLevel)}',
              style: GoogleFonts.inter(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: tierColor,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(AchievementEntity achievement) {
    if (achievement.id.contains('chapter')) return Icons.menu_book_rounded;
    if (achievement.id.contains('exercise')) {
      return Icons.fitness_center_rounded;
    }
    if (achievement.id.contains('dedicated')) return Icons.school_rounded;
    if (achievement.category == 'Experience') return Icons.star_rounded;
    if (achievement.category == 'Learning') return Icons.auto_stories_rounded;
    if (achievement.category == 'Mastery') return Icons.diamond_rounded;
    if (achievement.category == 'Dedication') {
      return Icons.event_available_rounded;
    }
    if (achievement.category == 'Streaks') {
      return Icons.local_fire_department_rounded;
    }
    return Icons.emoji_events_rounded;
  }
}
