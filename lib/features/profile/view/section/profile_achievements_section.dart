import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/home/data/achievement_entity.dart';
import 'package:modern_learner_production/features/home/data/home_achievement_data.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_achievement_badge.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_achievement_empty_state.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_achievement_shimmer.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_section_label.dart';

class ProfileAchievementsSection extends StatelessWidget {
  const ProfileAchievementsSection({
    super.key,
    required this.achievementState,
    required this.onViewAllTap,
    required this.onAchievementTap,
  });

  final AchievementState achievementState;
  final VoidCallback onViewAllTap;
  final ValueChanged<AchievementEntity> onAchievementTap;

  @override
  Widget build(BuildContext context) {
    final unlockedAchievements = achievementState.achievements
        .where((achievement) => !achievement.isLocked)
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const ProfileSectionLabel(text: 'ACHIEVEMENTS'),
            if (achievementState.achievements.isNotEmpty) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${achievementState.unlockedCount}/${achievementState.achievements.length}',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
            const Spacer(),
            GestureDetector(
              onTap: onViewAllTap,
              child: Text(
                'View all',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (achievementState.status == AchievementStatus.initial ||
            achievementState.status == AchievementStatus.loading)
          const ProfileAchievementShimmer()
        else if (unlockedAchievements.isEmpty)
          const ProfileAchievementEmptyState()
        else
          SizedBox(
            height: 148,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: unlockedAchievements.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final achievement = unlockedAchievements[index];
                return GestureDetector(
                  onTap: () => onAchievementTap(achievement),
                  child: ProfileAchievementBadge(achievement: achievement),
                );
              },
            ),
          ),
      ],
    );
  }
}
