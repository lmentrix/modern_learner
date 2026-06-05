import 'package:flutter/material.dart';

/// Centralised breakpoints and helpers for responsive layout.
///
/// Breakpoints:
///   compact  < 380   — very small phones
///   mobile   < 600   — normal phones
///   tablet   600–900 — tablets / large phones
///   desktop  ≥ 900   — desktops / large tablets
abstract final class Responsive {
  // ── Breakpoints ────────────────────────────────────────────────────────────
  static const double _compact = 380;
  static const double _tablet = 600;
  static const double _desktop = 900;

  /// Maximum width for centred content on wide screens.
  static const double maxContentWidth = 900;

  // ── Category helpers ───────────────────────────────────────────────────────
  static bool isCompact(BuildContext ctx) =>
      MediaQuery.sizeOf(ctx).width < _compact;

  static bool isMobile(BuildContext ctx) =>
      MediaQuery.sizeOf(ctx).width < _tablet;

  static bool isTablet(BuildContext ctx) {
    final w = MediaQuery.sizeOf(ctx).width;
    return w >= _tablet && w < _desktop;
  }

  static bool isDesktop(BuildContext ctx) =>
      MediaQuery.sizeOf(ctx).width >= _desktop;

  static bool isTabletOrDesktop(BuildContext ctx) =>
      MediaQuery.sizeOf(ctx).width >= _tablet;

  // ── Layout values ──────────────────────────────────────────────────────────

  /// Horizontal page padding.
  static double hPad(BuildContext ctx) {
    final w = MediaQuery.sizeOf(ctx).width;
    if (w < _compact) return 16;
    if (w >= _desktop) return 40;
    if (w >= _tablet) return 28;
    return 20;
  }

  /// Grid cross-axis count for card grids.
  static int gridCols(BuildContext ctx, {int mobileCols = 2}) {
    final w = MediaQuery.sizeOf(ctx).width;
    if (w >= _desktop) return mobileCols + 2;
    if (w >= _tablet) return mobileCols + 1;
    return mobileCols;
  }

  /// Standard body font size.
  static double bodySize(BuildContext ctx) {
    final w = MediaQuery.sizeOf(ctx).width;
    if (w < 360) return 12;
    if (w >= _desktop) return 16;
    if (w >= _tablet) return 15;
    return 14;
  }

  /// Wraps [child] in a centred, max-width constrained box.
  static Widget centred({required Widget child, double? maxWidth}) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? maxContentWidth),
        child: child,
      ),
    );
  }

  /// Returns [EdgeInsets] with responsive horizontal padding.
  static EdgeInsets pagePadding(BuildContext ctx, {double? vertical}) {
    final h = hPad(ctx);
    return vertical != null
        ? EdgeInsets.symmetric(horizontal: h, vertical: vertical)
        : EdgeInsets.symmetric(horizontal: h);
  }
}
