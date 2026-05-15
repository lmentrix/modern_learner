import 'package:flutter/material.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';

class ProfileAchievementShimmer extends StatelessWidget {
  const ProfileAchievementShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 148,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 4,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) => Container(
          width: 112,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh.withValues(alpha: 0.42),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
