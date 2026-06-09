import 'package:flutter/material.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';

abstract final class NewLessonPageConstants {
  static EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: 20);

  static LinearGradient get headerGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF14182E), AppColors.surface],
  );

  static LinearGradient get previewGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF232846), Color(0xFF171A29)],
  );
}
