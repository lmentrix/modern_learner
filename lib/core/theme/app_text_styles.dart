import 'package:flutter/material.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';

abstract final class AppTextStyles {
  static TextStyle get displayLarge => TextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    color: AppColors.onSurface,
  );

  static TextStyle get headlineLarge => TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: 0,
    color: AppColors.onSurface,
  );

  static TextStyle get headlineMedium => TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: AppColors.onSurface,
  );

  static TextStyle get titleLarge => TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: AppColors.onSurface,
  );

  static TextStyle get bodyLarge => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.15,
    color: AppColors.onSurface,
  );

  static TextStyle get bodyMedium => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    color: AppColors.onSurfaceVariant,
  );

  static TextStyle get labelLarge => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: AppColors.onSurface,
  );
}
