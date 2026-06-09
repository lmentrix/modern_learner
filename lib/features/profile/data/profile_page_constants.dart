import 'package:flutter/material.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';

abstract final class ProfilePageConstants {
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: 20);
  static double sectionSpacing = 28;
  static String roleLabel = 'Advanced Learner';
  static String levelLabel = 'LVL 8';
  static String versionLabel = 'Modern Learner · v1.0.0';

  static LinearGradient get headerGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF101327), AppColors.surface],
  );
}
