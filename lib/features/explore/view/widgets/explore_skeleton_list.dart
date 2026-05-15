import 'package:flutter/material.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';

class ExploreSkeletonList extends StatelessWidget {
  const ExploreSkeletonList({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverList.separated(
      itemCount: 4,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) => Container(
        height: 180,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh.withValues(alpha: 0.42),
          borderRadius: BorderRadius.circular(26),
        ),
      ),
    );
  }
}
