import 'package:flutter/material.dart';

import 'package:modern_learner_production/core/theme/app_theme_controller.dart';

class AppColorPalette {
  const AppColorPalette({
    required this.surface,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.surfaceBright,
    required this.primary,
    required this.primaryDim,
    required this.primaryContainer,
    required this.onPrimary,
    required this.secondary,
    required this.tertiary,
    required this.tertiaryContainer,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.outlineVariant,
    required this.error,
  });

  final Color surface;
  final Color surfaceContainerLowest;
  final Color surfaceContainerLow;
  final Color surfaceContainer;
  final Color surfaceContainerHigh;
  final Color surfaceContainerHighest;
  final Color surfaceBright;
  final Color primary;
  final Color primaryDim;
  final Color primaryContainer;
  final Color onPrimary;
  final Color secondary;
  final Color tertiary;
  final Color tertiaryContainer;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color outlineVariant;
  final Color error;

  LinearGradient get primaryGradient => LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [primaryDim, primary],
  );

  LinearGradient get tertiaryGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [tertiaryContainer, tertiary],
  );
}

abstract final class AppColors {
  static const AppColorPalette dark = AppColorPalette(
    surface: Color(0xFF0C0E17),
    surfaceContainerLowest: Color(0xFF000000),
    surfaceContainerLow: Color(0xFF11131D),
    surfaceContainer: Color(0xFF171924),
    surfaceContainerHigh: Color(0xFF1C1F2B),
    surfaceContainerHighest: Color(0xFF21253A),
    surfaceBright: Color(0xFF22263A),
    primary: Color(0xFFB1A0FF),
    primaryDim: Color(0xFF7E51FF),
    primaryContainer: Color(0xFF2A1F5C),
    onPrimary: Color(0xFF340090),
    secondary: Color(0xFF929BFA),
    tertiary: Color(0xFFB1FFCE),
    tertiaryContainer: Color(0xFF00FFA3),
    onSurface: Color(0xFFF0F0FD),
    onSurfaceVariant: Color(0xFFAAAAB7),
    outlineVariant: Color(0xFF464752),
    error: Color(0xFFFF6E84),
  );

  static const AppColorPalette light = AppColorPalette(
    surface: Color(0xFFF7F7FC),
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF1F2F8),
    surfaceContainer: Color(0xFFEBECF5),
    surfaceContainerHigh: Color(0xFFE3E5F0),
    surfaceContainerHighest: Color(0xFFD8DAE7),
    surfaceBright: Color(0xFFFFFFFF),
    primary: Color(0xFF6D4CFF),
    primaryDim: Color(0xFF5334D8),
    primaryContainer: Color(0xFFE7E1FF),
    onPrimary: Color(0xFFFFFFFF),
    secondary: Color(0xFF5661D9),
    tertiary: Color(0xFF0C8E61),
    tertiaryContainer: Color(0xFFCCF6E0),
    onSurface: Color(0xFF151622),
    onSurfaceVariant: Color(0xFF626475),
    outlineVariant: Color(0xFFD8DAE7),
    error: Color(0xFFD83A56),
  );

  static AppColorPalette get active {
    final preference = AppThemeController.instance.preference;
    if (preference == AppThemePreference.light) {
      return light;
    }
    if (preference == AppThemePreference.system) {
      final platformBrightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      return platformBrightness == Brightness.light ? light : dark;
    }
    return dark;
  }

  static Color get surface => active.surface;
  static Color get surfaceContainerLowest => active.surfaceContainerLowest;
  static Color get surfaceContainerLow => active.surfaceContainerLow;
  static Color get surfaceContainer => active.surfaceContainer;
  static Color get surfaceContainerHigh => active.surfaceContainerHigh;
  static Color get surfaceContainerHighest => active.surfaceContainerHighest;
  static Color get surfaceBright => active.surfaceBright;
  static Color get primary => active.primary;
  static Color get primaryDim => active.primaryDim;
  static Color get primaryContainer => active.primaryContainer;
  static Color get onPrimary => active.onPrimary;
  static Color get secondary => active.secondary;
  static Color get tertiary => active.tertiary;
  static Color get tertiaryContainer => active.tertiaryContainer;
  static Color get onSurface => active.onSurface;
  static Color get onSurfaceVariant => active.onSurfaceVariant;
  static Color get outlineVariant => active.outlineVariant;
  static Color get error => active.error;
  static LinearGradient get primaryGradient => active.primaryGradient;
  static LinearGradient get tertiaryGradient => active.tertiaryGradient;
}
