import 'package:flutter/material.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';

abstract final class NewLessonPageConstants {
  static const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: 20);

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF14182E), AppColors.surface],
  );

  static const LinearGradient previewGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF232846), Color(0xFF171A29)],
  );
}
