import 'package:flutter/material.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/achievement/model/achievement_model.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_xp_chip.dart';

class ProfileCourseXpBreakdown extends StatelessWidget {
  const ProfileCourseXpBreakdown({
    required this.data,
    required this.color,
    super.key,
  });

  final ProfileCourseXpModel data;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),
        Container(
          height: 1,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.35), Colors.transparent],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            ProfileXpChip(
              icon: Icons.fitness_center_rounded,
              label: 'Exercise XP  ${data.exerciseXp}',
              color: color,
            ),
            ProfileXpChip(
              icon: Icons.check_circle_outline_rounded,
              label: '${data.exercisesCompleted} exercises done',
              color: AppColors.tertiary,
            ),
            ProfileXpChip(
              icon: Icons.layers_rounded,
              label: '${data.chaptersUnlocked} chapters unlocked',
              color: AppColors.secondary,
            ),
          ],
        ),
      ],
    );
  }
}
