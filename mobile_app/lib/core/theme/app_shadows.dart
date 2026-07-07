import 'package:flutter/material.dart';

/// Elevation-based shadow tokens for custom containers.
///
/// Use these instead of raw BoxShadow to maintain consistency across the
/// design system.
class AppShadows {
  AppShadows._();

  // ─── Light Mode Shadows ───────────────────────────────────────────────────

  /// No shadow — flat cards with border.
  static const List<BoxShadow> none = [];

  /// Subtle lift — for cards in resting state.
  static const List<BoxShadow> xs = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    ),
  ];

  /// Small elevation — for interactive cards.
  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x05000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// Medium elevation — for dialogs, dropdowns.
  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color(0x08000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  /// Large elevation — for modals, floating panels.
  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 32,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  /// Extra large — for hero elements, splash screens.
  static const List<BoxShadow> xl = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 56,
      offset: Offset(0, 16),
    ),
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];

  // ─── Colored Shadows (Primary) ────────────────────────────────────────────

  /// Primary-colored glow — for selected elements.
  static const List<BoxShadow> primaryGlow = [
    BoxShadow(
      color: Color(0x330D6E6E),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  /// Success-colored glow — for the success screen.
  static const List<BoxShadow> successGlow = [
    BoxShadow(
      color: Color(0x331B8A1B),
      blurRadius: 20,
      offset: Offset(0, 6),
    ),
  ];

  // ─── Dark Mode Shadows ────────────────────────────────────────────────────

  static const List<BoxShadow> smDark = [
    BoxShadow(
      color: Color(0x28000000),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> mdDark = [
    BoxShadow(
      color: Color(0x3D000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];
}
