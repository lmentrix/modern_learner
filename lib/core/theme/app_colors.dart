import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Surface depth stack ───────────────────────────────────────────────────
  static const Color surface = Color(0xFF0C0E17);
  static const Color surfaceContainerLowest = Color(0xFF000000);
  static const Color surfaceContainerLow = Color(0xFF11131D);
  static const Color surfaceContainer = Color(0xFF171924);
  static const Color surfaceContainerHigh = Color(0xFF1C1F2B);
  static const Color surfaceContainerHighest = Color(0xFF21253A);
  static const Color surfaceBright = Color(0xFF22263A);

  // ── Primary ───────────────────────────────────────────────────────────────
  static const Color primary = Color(0xFFB1A0FF);
  static const Color primaryDim = Color(0xFF7E51FF);
  static const Color primaryContainer = Color(0xFF2A1F5C);
  static const Color onPrimary = Color(0xFF340090);

  // ── Secondary ─────────────────────────────────────────────────────────────
  static const Color secondary = Color(0xFF929BFA);

  // ── Tertiary (success / highlight) ────────────────────────────────────────
  static const Color tertiary = Color(0xFFB1FFCE);
  static const Color tertiaryContainer = Color(0xFF00FFA3);

  // ── On-surface text ───────────────────────────────────────────────────────
  static const Color onSurface = Color(0xFFF0F0FD);
  static const Color onSurfaceVariant = Color(0xFFAAAAB7);

  // ── Outline ───────────────────────────────────────────────────────────────
  static const Color outlineVariant = Color(0xFF464752);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFFF6E84);

  // ── Gradient helpers ──────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [primaryDim, primary],
  );

  static const LinearGradient tertiaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [tertiaryContainer, tertiary],
  );
}
