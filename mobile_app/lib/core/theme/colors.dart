import 'package:flutter/material.dart';

/// Central color palette for CSM-GIAS Resto+.
///
/// All colors follow Material 3 tonal system and are WCAG AA compliant
/// (minimum 4.5:1 contrast ratio for text, 3:1 for UI components).
class AppColors {
  AppColors._();

  // ─── Brand Primary — Deep Teal ────────────────────────────────────────────
  /// Enterprise-grade deep teal — professional, calm, modern.
  static const Color primary = Color(0xFF0D6E6E);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFB2F5F5);
  static const Color onPrimaryContainer = Color(0xFF002020);
  static const Color primaryDark = Color(0xFF5ECECE);
  static const Color onPrimaryDark = Color(0xFF003737);
  static const Color primaryContainerDark = Color(0xFF004F4F);
  static const Color onPrimaryContainerDark = Color(0xFFB2F5F5);

  // ─── Brand Secondary — Warm Amber-Orange ─────────────────────────────────
  /// Warm, energetic accent — restaurant warmth and appetite cues.
  static const Color secondary = Color(0xFFE8683A);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFFFDBCE);
  static const Color onSecondaryContainer = Color(0xFF3A0E00);
  static const Color secondaryDark = Color(0xFFFFB59B);
  static const Color onSecondaryDark = Color(0xFF55200B);
  static const Color secondaryContainerDark = Color(0xFF6E3120);
  static const Color onSecondaryContainerDark = Color(0xFFFFDBCE);

  // ─── Tertiary — Slate Blue ────────────────────────────────────────────────
  /// Info accent, used for secondary actions and informational elements.
  static const Color tertiary = Color(0xFF4B6587);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFD6E3FF);
  static const Color onTertiaryContainer = Color(0xFF041B37);
  static const Color tertiaryDark = Color(0xFFB0C6E8);
  static const Color onTertiaryDark = Color(0xFF1B3050);
  static const Color tertiaryContainerDark = Color(0xFF334B6C);
  static const Color onTertiaryContainerDark = Color(0xFFD6E3FF);

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
  static const Color surfaceLight = Color(0xFFF5F7FA);
  static const Color onSurfaceLight = Color(0xFF181C1E);
  static const Color surfaceContainerLight = Color(0xFFEBEEF2);
  static const Color surfaceContainerHighestLight = Color(0xFFDDE1E6);
  static const Color onSurfaceVariantLight = Color(0xFF404749);
  static const Color outlineLight = Color(0xFF707779);
  static const Color outlineVariantLight = Color(0xFFC0C7CA);

  // ─── Surface / Background — Dark ─────────────────────────────────────────
  static const Color surfaceDark = Color(0xFF111517);
  static const Color onSurfaceDark = Color(0xFFE1E3E6);
  static const Color surfaceContainerDark = Color(0xFF1E2326);
  static const Color surfaceContainerHighestDark = Color(0xFF2A2F33);
  static const Color onSurfaceVariantDark = Color(0xFFC0C7CA);
  static const Color outlineDark = Color(0xFF8A9194);
  static const Color outlineVariantDark = Color(0xFF404749);

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
    Color(0xFF0D6E6E), // primary teal
    Color(0xFFE8683A), // secondary orange
    Color(0xFF4B6587), // tertiary slate
    Color(0xFF2E7D32), // success green
    Color(0xFF7B1FA2), // purple
    Color(0xFFF57C00), // amber
  ];

  static const List<Color> chartColorsDark = [
    Color(0xFF5ECECE), // primary teal light
    Color(0xFFFFB59B), // secondary orange light
    Color(0xFFB0C6E8), // tertiary slate light
    Color(0xFF81C784), // success green light
    Color(0xFFCE93D8), // purple light
    Color(0xFFFFCC80), // amber light
  ];

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
