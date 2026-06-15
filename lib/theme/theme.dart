import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ────────────────────────────────────────────────────────────────────────────
// Colors
// ────────────────────────────────────────────────────────────────────────────

abstract final class EduColors {
  // Backgrounds
  static const bg = Color(0xFFF7F5FF);
  static const surface = Color(0xFFFFFFFF);
  static const splash = Color(0xFFC4B5FD);

  // Brand
  static const primary = Color(0xFFA78BFA);
  static const primaryLight = Color(0xFFE9D5FF);

  // Accents
  static const accentGreen = Color(0xFFBBF0D9);
  static const accentYellow = Color(0xFFFDE68A);
  static const accentTeal = Color(0xFFA7F3D0);
  static const star = Color(0xFFF59E0B);

  // Text
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
  static const textInverse = Color(0xFFFFFFFF);

  // Border
  static const border = Color(0xFFE5E7EB);

  // Shadows
  static final shadowCard = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.06),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
  ];
  static final shadowRaised = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.10),
      blurRadius: 24,
      offset: const Offset(0, 4),
    ),
  ];
  static final shadowFloat = [
    BoxShadow(
      color: const Color(0xFFA78BFA).withValues(alpha: 0.18),
      blurRadius: 32,
      offset: const Offset(0, 8),
    ),
  ];
}

// ────────────────────────────────────────────────────────────────────────────
// Radius tokens
// ────────────────────────────────────────────────────────────────────────────

abstract final class EduRadius {
  static const sm = Radius.circular(8);
  static const md = Radius.circular(16);
  static const lg = Radius.circular(20);
  static const xl = Radius.circular(28);
  static const pill = Radius.circular(999);

  static const borderSm = BorderRadius.all(sm);
  static const borderMd = BorderRadius.all(md);
  static const borderLg = BorderRadius.all(lg);
  static const borderXl = BorderRadius.all(xl);
  static const borderPill = BorderRadius.all(pill);
}

// ────────────────────────────────────────────────────────────────────────────
// Spacing tokens
// ────────────────────────────────────────────────────────────────────────────

abstract final class EduSpacing {
  static const s1 = 4.0;
  static const s2 = 8.0;
  static const s3 = 12.0;
  static const s4 = 16.0;
  static const s5 = 20.0;
  static const s6 = 24.0;
  static const s8 = 32.0;
  static const s10 = 40.0;
  static const s12 = 48.0;
  static const s16 = 64.0;

  static const pagePadding = EdgeInsets.symmetric(horizontal: s6);
  static const cardPadding = EdgeInsets.all(s5);
}

// ────────────────────────────────────────────────────────────────────────────
// Typography
// ────────────────────────────────────────────────────────────────────────────

abstract final class EduTextStyles {
  static TextTheme get textTheme => TextTheme(
    // ── Display / Hero — Plus Jakarta Sans 800 ──────────────────────────
    displayLarge: GoogleFonts.plusJakartaSans(
      fontSize: 36,
      fontWeight: FontWeight.w800,
      height: 1.1,
      letterSpacing: -0.5,
      color: EduColors.textPrimary,
    ),
    displayMedium: GoogleFonts.plusJakartaSans(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      height: 1.2,
      letterSpacing: -0.3,
      color: EduColors.textPrimary,
    ),
    displaySmall: GoogleFonts.plusJakartaSans(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      height: 1.3,
      color: EduColors.textPrimary,
    ),

    // ── Section headings — Plus Jakarta Sans 700 ─────────────────────
    headlineLarge: GoogleFonts.plusJakartaSans(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      height: 1.3,
      color: EduColors.textPrimary,
    ),
    headlineMedium: GoogleFonts.plusJakartaSans(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      height: 1.3,
      color: EduColors.textPrimary,
    ),
    headlineSmall: GoogleFonts.plusJakartaSans(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      height: 1.4,
      color: EduColors.textPrimary,
    ),

    // ── Card titles — Plus Jakarta Sans 600 ──────────────────────────
    titleLarge: GoogleFonts.plusJakartaSans(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: EduColors.textPrimary,
    ),
    titleMedium: GoogleFonts.plusJakartaSans(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: EduColors.textPrimary,
    ),
    titleSmall: GoogleFonts.plusJakartaSans(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      height: 1.4,
      color: EduColors.textPrimary,
    ),

    // ── Body — Inter 400 ─────────────────────────────────────────────
    bodyLarge: GoogleFonts.inter(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      height: 1.6,
      color: EduColors.textPrimary,
    ),
    bodyMedium: GoogleFonts.inter(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.6,
      color: EduColors.textSecondary,
    ),
    bodySmall: GoogleFonts.inter(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      height: 1.5,
      color: EduColors.textSecondary,
    ),

    // ── Label / Tag / Meta — Inter 500 ───────────────────────────────
    labelLarge: GoogleFonts.inter(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      height: 1.4,
      letterSpacing: 0.2,
      color: EduColors.textSecondary,
    ),
    labelMedium: GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      height: 1.4,
      letterSpacing: 0.3,
      color: EduColors.textSecondary,
    ),
    labelSmall: GoogleFonts.inter(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      height: 1.4,
      letterSpacing: 0.4,
      color: EduColors.textSecondary,
    ),
  );
}

// ────────────────────────────────────────────────────────────────────────────
// ThemeData
// ────────────────────────────────────────────────────────────────────────────

abstract final class EduTheme {
  static ThemeData get light {
    final text = EduTextStyles.textTheme;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: EduColors.primary,
      brightness: Brightness.light,
      surface: EduColors.bg,
      primary: EduColors.primary,
      onPrimary: EduColors.textInverse,
      secondary: EduColors.primaryLight,
      onSecondary: EduColors.textPrimary,
      tertiary: EduColors.accentGreen,
      onTertiary: EduColors.textPrimary,
      error: const Color(0xFFDC2626),
      onSurface: EduColors.textPrimary,
      onSurfaceVariant: EduColors.textSecondary,
      outline: EduColors.border,
      outlineVariant: EduColors.border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: EduColors.bg,
      textTheme: text,

      // ── AppBar ────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: EduColors.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: text.headlineSmall,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: const IconThemeData(color: EduColors.textPrimary, size: 24),
      ),

      // ── NavigationBar ─────────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: EduColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: EduColors.primaryLight,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: EduColors.primary, size: 24);
          }
          return const IconThemeData(color: EduColors.textSecondary, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final base = text.labelMedium!;
          if (states.contains(WidgetState.selected)) {
            return base.copyWith(
              color: EduColors.primary,
              fontWeight: FontWeight.w600,
            );
          }
          return base;
        }),
        elevation: 0,
        height: 64,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),

      // ── ElevatedButton — dark pill CTA ────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: EduColors.textPrimary,
          foregroundColor: EduColors.textInverse,
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: const StadiumBorder(),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          elevation: 0,
        ),
      ),

      // ── OutlinedButton ────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: EduColors.textPrimary,
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: const StadiumBorder(),
          side: const BorderSide(color: EduColors.border),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── TextButton ────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: EduColors.primary,
          textStyle: text.labelLarge?.copyWith(
            fontSize: 14,
            color: EduColors.primary,
          ),
        ),
      ),

      // ── InputDecoration ───────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: EduColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: const OutlineInputBorder(
          borderRadius: EduRadius.borderMd,
          borderSide: BorderSide(color: EduColors.border),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: EduRadius.borderMd,
          borderSide: BorderSide(color: EduColors.border),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: EduRadius.borderMd,
          borderSide: BorderSide(color: EduColors.primary, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: EduRadius.borderMd,
          borderSide: BorderSide(color: Color(0xFFDC2626)),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: EduRadius.borderMd,
          borderSide: BorderSide(color: Color(0xFFDC2626), width: 1.5),
        ),
        hintStyle: text.bodyMedium,
        errorStyle: text.bodySmall?.copyWith(color: const Color(0xFFDC2626)),
      ),

      // ── Card ──────────────────────────────────────────────────────────────
      cardTheme: const CardThemeData(
        color: EduColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: EduRadius.borderXl),
        margin: EdgeInsets.zero,
      ),

      // ── Chip ──────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: EduColors.primaryLight,
        selectedColor: EduColors.primary,
        labelStyle: text.labelLarge?.copyWith(color: EduColors.textPrimary),
        shape: const StadiumBorder(),
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: EduColors.border,
        thickness: 1,
        space: 0,
      ),

      // ── BottomSheet ───────────────────────────────────────────────────────
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: EduColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: EduRadius.xl),
        ),
        showDragHandle: true,
        dragHandleColor: EduColors.border,
      ),

      // ── Dialog ────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: EduColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: EduRadius.borderLg),
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium,
      ),

      // ── SnackBar ──────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: EduColors.textPrimary,
        contentTextStyle: text.bodyMedium?.copyWith(
          color: EduColors.textInverse,
        ),
        shape: const RoundedRectangleBorder(borderRadius: EduRadius.borderMd),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),

      // ── Switch ────────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? EduColors.primary
              : EduColors.textSecondary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? EduColors.primaryLight
              : EduColors.border,
        ),
      ),

      // ── ProgressIndicator ─────────────────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: EduColors.primary,
        linearTrackColor: EduColors.primaryLight,
        circularTrackColor: EduColors.primaryLight,
        linearMinHeight: 8,
      ),

      // ── FloatingActionButton (Arrow FAB) ──────────────────────────────────
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: EduColors.primaryLight,
        foregroundColor: EduColors.primary,
        elevation: 0,
        shape: CircleBorder(),
      ),

      // ── ListTile ──────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        tileColor: EduColors.surface,
        shape: const RoundedRectangleBorder(borderRadius: EduRadius.borderLg),
        titleTextStyle: text.titleMedium,
        subtitleTextStyle: text.bodyMedium,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      ),
    );
  }
}
