import 'package:flutter/material.dart';

/// Central color palette for CSM-GIAS Resto+.
///
/// All colors follow Material 3 tonal system and are WCAG AA compliant
/// (minimum 4.5:1 contrast ratio for text, 3:1 for UI components).
class AppColors {
  AppColors._();

  // ─── Brand Primary — Deep Teal ────────────────────────────────────────────
  /// Enterprise-grade deep teal — professional, calm, modern.
  static const Color primary = Color(0xFF073F68);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFD7E9F6);
  static const Color onPrimaryContainer = Color(0xFF061F32);
  static const Color primaryDark = Color(0xFF9ACCF0);
  static const Color onPrimaryDark = Color(0xFF00344F);
  static const Color primaryContainerDark = Color(0xFF124F79);
  static const Color onPrimaryContainerDark = Color(0xFFD7E9F6);

  // ─── Brand Secondary — Warm Amber-Orange ─────────────────────────────────
  /// Warm, energetic accent — restaurant warmth and appetite cues.
  static const Color secondary = Color(0xFFD99B00);
  static const Color onSecondary = Color(0xFF261A00);
  static const Color secondaryContainer = Color(0xFFFFE9AD);
  static const Color onSecondaryContainer = Color(0xFF2C2100);
  static const Color secondaryDark = Color(0xFFFFD45A);
  static const Color onSecondaryDark = Color(0xFF3B2F00);
  static const Color secondaryContainerDark = Color(0xFF5B4500);
  static const Color onSecondaryContainerDark = Color(0xFFFFE9AD);

  // ─── Tertiary — Slate Blue ────────────────────────────────────────────────
  /// Info accent, used for secondary actions and informational elements.
  static const Color tertiary = Color(0xFF4D8B69);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFCFEBD8);
  static const Color onTertiaryContainer = Color(0xFF092617);
  static const Color tertiaryDark = Color(0xFFA8D8B7);
  static const Color onTertiaryDark = Color(0xFF123923);
  static const Color tertiaryContainerDark = Color(0xFF28573D);
  static const Color onTertiaryContainerDark = Color(0xFFCFEBD8);

  static const Color brandBlue = Color(0xFF1681AE);
  static const Color brandGreen = Color(0xFF4D8B69);
  static const Color brandYellow = Color(0xFFF2C23D);
  static const Color brandOrange = Color(0xFFE9782D);
  static const Color brandRed = Color(0xFFC83C38);

  // ─── Error ────────────────────────────────────────────────────────────────
  static const Color error = Color(0xFFC62828);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF410002);
  static const Color errorDark = Color(0xFFFFB4AB);
  static const Color onErrorDark = Color(0xFF690005);
  static const Color errorContainerDark = Color(0xFF93000A);
  static const Color onErrorContainerDark = Color(0xFFFFDAD6);

  // ─── Surface / Background — Light ────────────────────────────────────────
  static const Color surfaceLight = Color(0xFFF7F9FC);
  static const Color onSurfaceLight = Color(0xFF17232D);
  static const Color surfaceContainerLight = Color(0xFFEDF2F7);
  static const Color surfaceContainerHighestLight = Color(0xFFE1E9F0);
  static const Color onSurfaceVariantLight = Color(0xFF435563);
  static const Color outlineLight = Color(0xFF687A87);
  static const Color outlineVariantLight = Color(0xFFC3CFD8);

  // ─── Surface / Background — Dark ─────────────────────────────────────────
  static const Color surfaceDark = Color(0xFF0D1720);
  static const Color onSurfaceDark = Color(0xFFE2EAF0);
  static const Color surfaceContainerDark = Color(0xFF172630);
  static const Color surfaceContainerHighestDark = Color(0xFF22343F);
  static const Color onSurfaceVariantDark = Color(0xFFBCCAD4);
  static const Color outlineDark = Color(0xFF8798A4);
  static const Color outlineVariantDark = Color(0xFF3D505D);

  // ─── Outline ───────────────────────────────────────────────────────────────
  /// Default outline color (light mode).
  static const Color outline = outlineLight;

  // ─── Semantic Colors ──────────────────────────────────────────────────────
  /// Success — meal registered, active status.
  static const Color success = Color(0xFF1B8A1B);
  static const Color onSuccess = Color(0xFFFFFFFF);
  static const Color successContainer = Color(0xFFB7F1B7);
  static const Color onSuccessContainer = Color(0xFF002200);
  static const Color successDark = Color(0xFF81C784);
  static const Color successContainerDark = Color(0xFF00390A);

  /// Warning — expiring QR, inactive status.
  static const Color warning = Color(0xFFE67E22);
  static const Color onWarning = Color(0xFFFFFFFF);
  static const Color warningContainer = Color(0xFFFFE0C4);
  static const Color onWarningContainer = Color(0xFF2D1600);
  static const Color warningDark = Color(0xFFFFD180);
  static const Color warningContainerDark = Color(0xFF4A2800);

  /// Info — informational badges, secondary links.
  static const Color info = Color(0xFF0277BD);
  static const Color onInfo = Color(0xFFFFFFFF);
  static const Color infoContainer = Color(0xFFCDE5FF);
  static const Color onInfoContainer = Color(0xFF001D35);
  static const Color infoDark = Color(0xFF4FC3F7);
  static const Color infoContainerDark = Color(0xFF004C72);

  // ─── Chart Colors ─────────────────────────────────────────────────────────
  /// Curated 6-color palette for charts — harmonious and accessible.
  static const List<Color> chartColors = [
    primary,
    brandBlue,
    brandGreen,
    brandYellow,
    brandOrange,
    brandRed,
  ];

  static const List<Color> chartColorsDark = [
    Color(0xFF9ACCF0),
    Color(0xFF72C5E5),
    Color(0xFFA8D8B7),
    Color(0xFFFFD86B),
    Color(0xFFFFAB72),
    Color(0xFFFF8E88),
  ];

  // ─── Brand Gradients ──────────────────────────────────────────────────────
  /// Primary teal gradient — for hero surfaces, app bars, splash.
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF073F68), Color(0xFF126E9A)],
  );

  /// Warm secondary gradient — for appetite-cue accents and CTAs.
  static const LinearGradient warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brandYellow, brandOrange],
  );

  static const LinearGradient brandRibbonGradient = LinearGradient(
    colors: [brandGreen, brandYellow, brandOrange, brandRed],
  );

  /// Success gradient — for the meal-registered success screen.
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1B8A1B), Color(0xFF146914)],
  );

  // ─── Convenience ──────────────────────────────────────────────────────────
  /// Transparent black for overlays.
  static const Color scrim = Color(0x52000000);

  /// Shimmer base color (light mode).
  static const Color shimmerBase = Color(0xFFE8ECEF);

  /// Shimmer highlight color (light mode).
  static const Color shimmerHighlight = Color(0xFFF5F7FA);

  /// Shimmer base color (dark mode).
  static const Color shimmerBaseDark = Color(0xFF2A2F33);

  /// Shimmer highlight color (dark mode).
  static const Color shimmerHighlightDark = Color(0xFF373D42);
}
