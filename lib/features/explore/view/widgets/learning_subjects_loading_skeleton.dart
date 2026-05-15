import 'package:flutter/material.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';

class LearningSubjectsLoadingSkeleton extends StatelessWidget {
  const LearningSubjectsLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final cols = w >= 900
        ? 4
        : w >= 600
        ? 3
        : 2;
    final hPad = w >= 600 ? 28.0 : 20.0;
    final ratio = w >= 600 ? 0.88 : 0.85;

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: hPad),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          childAspectRatio: ratio,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) => Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh.withValues(alpha: 0.42),
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          childCount: cols * 2,
        ),
      ),
    );
  }
}
