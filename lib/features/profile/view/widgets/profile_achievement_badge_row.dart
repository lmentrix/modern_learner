import 'package:flutter/material.dart';
import 'package:modern_learner_production/features/achievement/model/achievement_model.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_achievement_badge.dart';

class ProfileAchievementBadgeRow extends StatelessWidget {
  const ProfileAchievementBadgeRow({required this.achievements, super.key});

  final List<Achievement> achievements;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: achievements.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final achievement = achievements[index];
          return ProfileAchievementBadge(achievement: achievement);
        },
      ),
    );
  }
}
