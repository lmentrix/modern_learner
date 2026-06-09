import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';

abstract final class AppTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.dark.surface,
    colorScheme: ColorScheme.dark(
      surface: AppColors.dark.surface,
      primary: AppColors.dark.primary,
      secondary: AppColors.dark.secondary,
      tertiary: AppColors.dark.tertiary,
      onSurface: AppColors.dark.onSurface,
      error: AppColors.dark.error,
    ),
    textTheme: _textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: GoogleFonts.spaceGrotesk(
        color: AppColors.dark.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.light.surface,
    colorScheme: ColorScheme.light(
      surface: AppColors.light.surface,
      primary: AppColors.light.primary,
      secondary: AppColors.light.secondary,
      tertiary: AppColors.light.tertiary,
      onSurface: AppColors.light.onSurface,
      error: AppColors.light.error,
    ),
    textTheme: _lightTextTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: GoogleFonts.spaceGrotesk(
        color: AppColors.light.onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: IconThemeData(color: AppColors.light.onSurface),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.light.primary,
      thumbColor: AppColors.light.primary,
      inactiveTrackColor: AppColors.light.outlineVariant.withValues(
        alpha: 0.24,
      ),
    ),
  );

  static TextTheme get _textTheme => _buildTextTheme(
    onSurface: AppColors.dark.onSurface,
    onSurfaceVariant: AppColors.dark.onSurfaceVariant,
  );

  static TextTheme get _lightTextTheme => _buildTextTheme(
    onSurface: AppColors.light.onSurface,
    onSurfaceVariant: AppColors.light.onSurfaceVariant,
  );

  static TextTheme _buildTextTheme({
    required Color onSurface,
    required Color onSurfaceVariant,
  }) => TextTheme(
    displayLarge: GoogleFonts.spaceGrotesk(
      fontSize: 52,
      fontWeight: FontWeight.w700,
      color: onSurface,
      letterSpacing: -1.5,
      height: 1.1,
    ),
    displayMedium: GoogleFonts.spaceGrotesk(
      fontSize: 40,
      fontWeight: FontWeight.w700,
      color: onSurface,
      letterSpacing: -1.0,
      height: 1.15,
    ),
    displaySmall: GoogleFonts.spaceGrotesk(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      color: onSurface,
      letterSpacing: -0.5,
    ),
    headlineLarge: GoogleFonts.spaceGrotesk(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      color: onSurface,
    ),
    headlineMedium: GoogleFonts.spaceGrotesk(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: onSurface,
    ),
    headlineSmall: GoogleFonts.spaceGrotesk(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: onSurface,
    ),
    titleLarge: GoogleFonts.spaceGrotesk(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: onSurface,
    ),
    titleMedium: GoogleFonts.spaceGrotesk(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: onSurface,
    ),
    bodyLarge: GoogleFonts.inter(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      color: onSurface,
      height: 1.6,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: onSurfaceVariant,
      height: 1.6,
    ),
    labelLarge: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: onSurfaceVariant,
      letterSpacing: 1.2,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: onSurfaceVariant,
      letterSpacing: 1.4,
    ),
  );
}
