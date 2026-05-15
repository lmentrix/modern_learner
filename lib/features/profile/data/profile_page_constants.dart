import 'package:flutter/material.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';

abstract final class ProfilePageConstants {
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: 20);
  static const double sectionSpacing = 28;
  static const String roleLabel = 'Advanced Learner';
  static const String levelLabel = 'LVL 8';
  static const String versionLabel = 'Modern Learner · v1.0.0';

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF101327), AppColors.surface],
  );
}
