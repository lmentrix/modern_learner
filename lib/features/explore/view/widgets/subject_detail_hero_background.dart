import 'package:flutter/material.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';

class SubjectDetailHeroBackground extends StatelessWidget {
  const SubjectDetailHeroBackground({super.key, required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [accent.withValues(alpha: 0.30), AppColors.surface],
          ),
        ),
      ),
    );
  }
}
