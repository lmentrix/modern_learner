import 'package:flutter/material.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';

abstract final class NewLessonPageConstants {
  static EdgeInsets pagePadding = const EdgeInsets.symmetric(horizontal: 20);

  static LinearGradient get headerGradient => LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppColors.surfaceContainerLow.withValues(alpha: 0.78),
      AppColors.surfaceContainerLow.withValues(alpha: 0.36),
      AppColors.surface,
    ],
    stops: const [0, 0.62, 1],
  );

  static LinearGradient get previewGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.surfaceContainerLow,
      AppColors.surfaceContainerLow,
      AppColors.surfaceContainer,
    ],
    stops: const [0, 0.68, 1],
  );
}
