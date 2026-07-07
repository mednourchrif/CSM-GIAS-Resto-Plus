import 'package:flutter/material.dart';
import '../../../core/theme/spacing.dart';

/// Responsive layout helper.
///
/// Provides breakpoint-aware layout selection and orientation utilities.
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  // ─── Breakpoints ──────────────────────────────────────────────────────────

  static const double mobileBreakpoint = Spacing.mobileBreakpoint;
  static const double tabletBreakpoint = Spacing.tabletBreakpoint;
  static const double desktopBreakpoint = Spacing.desktopBreakpoint;

  // ─── Static Utilities ────────────────────────────────────────────────────

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < mobileBreakpoint;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= mobileBreakpoint && w < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= tabletBreakpoint;

  static bool isLandscape(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.landscape;

  static bool isPortrait(BuildContext context) =>
      MediaQuery.orientationOf(context) == Orientation.portrait;

  /// Number of grid columns based on screen width.
  static int gridColumns(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= desktopBreakpoint) return 4;
    if (w >= tabletBreakpoint) return 3;
    if (w >= mobileBreakpoint) return 2;
    return 2;
  }

  /// Horizontal page padding appropriate for screen size.
  static EdgeInsets screenPadding(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= desktopBreakpoint) return const EdgeInsets.symmetric(horizontal: Spacing.xxl);
    if (w >= tabletBreakpoint) return const EdgeInsets.symmetric(horizontal: Spacing.xl);
    return const EdgeInsets.symmetric(horizontal: Spacing.md);
  }

  /// Constrain content width for readability on wide screens.
  static BoxConstraints contentConstraints(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= desktopBreakpoint) {
      return const BoxConstraints(maxWidth: Spacing.maxContentWidthFull);
    }
    if (w >= tabletBreakpoint) {
      return const BoxConstraints(maxWidth: Spacing.maxContentWidthWide);
    }
    return const BoxConstraints.expand();
  }

  // ─── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= tabletBreakpoint && desktop != null) {
          return desktop!;
        }
        if (constraints.maxWidth >= mobileBreakpoint && tablet != null) {
          return tablet!;
        }
        return mobile;
      },
    );
  }
}
