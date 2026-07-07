import 'package:flutter/material.dart';

/// Design token system for CSM-GIAS Resto+.
///
/// All values follow the 8dp grid. Use these constants throughout the app
/// instead of hardcoded numbers.
class Spacing {
  Spacing._();

  // ─── Spacing Scale (8dp grid) ─────────────────────────────────────────────
  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  // ─── Border Radius Scale ──────────────────────────────────────────────────
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusXxl = 32.0;
  static const double radiusFull = 9999.0;

  // ─── Elevation Scale ──────────────────────────────────────────────────────
  static const double elevationNone = 0.0;
  static const double elevationXs = 1.0;
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;
  static const double elevationXl = 16.0;

  // ─── Icon Sizes ───────────────────────────────────────────────────────────
  static const double iconXs = 14.0;
  static const double iconSm = 18.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;
  static const double iconXxl = 64.0;
  static const double iconHero = 96.0;

  // ─── Touch Targets ────────────────────────────────────────────────────────
  /// Minimum touch target size (WCAG 2.5.5).
  static const double minTouchTarget = 48.0;

  // ─── Responsive Breakpoints ───────────────────────────────────────────────
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1280.0;

  // ─── Page Content Max Widths ─────────────────────────────────────────────
  static const double maxContentWidthNarrow = 480.0;
  static const double maxContentWidthMedium = 720.0;
  static const double maxContentWidthWide = 960.0;
  static const double maxContentWidthFull = 1200.0;
}

/// Animation duration tokens.
class AppDurations {
  AppDurations._();

  static const Duration fastest = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration slower = Duration(milliseconds: 700);
  static const Duration slowest = Duration(milliseconds: 1000);

  /// Auto-redirect duration on success screen.
  static const Duration successRedirect = Duration(seconds: 4);

  /// Debounce duration for search fields.
  static const Duration searchDebounce = Duration(milliseconds: 400);

  /// Shimmer cycle duration.
  static const Duration shimmerCycle = Duration(milliseconds: 1200);
}

/// Animation curve tokens.
///
/// [Curves] members are NOT Dart compile-time constants, so these must be
/// `static final`, not `static const`.
class AppCurves {
  AppCurves._();

  static final Curve standard = Curves.easeInOut;
  static final Curve enter = Curves.easeOut;
  static final Curve exit = Curves.easeIn;
  static final Curve emphasized = Curves.easeInOutCubicEmphasized;
  static final Curve bounce = Curves.elasticOut;
  static final Curve decelerate = Curves.decelerate;
}
