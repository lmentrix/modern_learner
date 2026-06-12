import 'package:flutter/material.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';

Color profileAvatarColor(String name) {
  final trimmedName = name.trim();
  if (trimmedName.isEmpty) return AppColors.primary;

  final letter = trimmedName[0].toUpperCase();

  final colors = <Color>[
    AppColors.primary,
    AppColors.secondary,
    AppColors.tertiary,
    AppColors.error,
    AppColors.primaryDim,
    AppColors.tertiaryContainer,
    Color.lerp(AppColors.primary, AppColors.secondary, 0.45) ??
        AppColors.primary,
    Color.lerp(AppColors.secondary, AppColors.tertiary, 0.38) ??
        AppColors.secondary,
    Color.lerp(AppColors.primaryDim, AppColors.error, 0.42) ??
        AppColors.primaryDim,
    Color.lerp(AppColors.tertiaryContainer, AppColors.primary, 0.36) ??
        AppColors.tertiaryContainer,
  ];

  final index = letter.codeUnitAt(0) % colors.length;

  return colors[index];
}
