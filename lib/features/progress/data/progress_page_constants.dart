import 'package:flutter/material.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';

abstract final class ProgressPageConstants {
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: 20);
  static const double sectionSpacing = 28;
  static const double cardRadius = 28;
  static const double barChartHeight = 108;

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF101327), AppColors.surface],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF232846), Color(0xFF171A29)],
  );

  static const String emptyTitle = 'Build a roadmap to unlock your progress';
  static const String emptyBody =
      'Create a voice lesson or a school course from Explore, then come back '
      'to track momentum, weekly rhythm, and chapter milestones.';
}
