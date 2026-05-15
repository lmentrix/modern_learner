import 'package:flutter/material.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';

class ExploreSkeletonBox extends StatelessWidget {
  const ExploreSkeletonBox({
    super.key,
    required this.height,
    required this.radius,
  });

  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
