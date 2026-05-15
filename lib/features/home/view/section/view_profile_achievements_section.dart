import 'package:flutter/material.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/home/view/widgets/view_profile_mini_achievement.dart';

class ViewProfileAchievementsSection extends StatelessWidget {
  const ViewProfileAchievementsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: const [
          ViewProfileMiniAchievement(
            emoji: '🔥',
            title: 'Week Streak',
            color: Color(0xFFFF9500),
          ),
          SizedBox(width: 12),
          ViewProfileMiniAchievement(
            emoji: '⭐',
            title: 'XP Master',
            color: AppColors.tertiaryContainer,
          ),
          SizedBox(width: 12),
          ViewProfileMiniAchievement(
            emoji: '📚',
            title: 'Bookworm',
            color: AppColors.primary,
          ),
          SizedBox(width: 12),
          ViewProfileMiniAchievement(
            emoji: '🎯',
            title: 'Perfectionist',
            color: AppColors.secondary,
          ),
          SizedBox(width: 12),
          ViewProfileMiniAchievement(
            emoji: '🏆',
            title: 'Champion',
            color: Color(0xFFFFD700),
            isLocked: true,
          ),
        ],
      ),
    );
  }
}
