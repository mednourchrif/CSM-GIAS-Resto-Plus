import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography system for CSM-GIAS Resto+.
///
/// Uses Inter as the primary typeface — a highly legible, enterprise-grade
/// sans-serif optimized for screen rendering and UI interfaces.
class AppTypography {
  AppTypography._();

  static TextTheme get textTheme {
    return TextTheme(
      // ── Display ──────────────────────────────────────────────────────────
      displayLarge: GoogleFonts.inter(
        fontSize: 57,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.25,
        height: 1.12,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 45,
        fontWeight: FontWeight.w400,
        height: 1.16,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        height: 1.22,
      ),

      // ── Headline ─────────────────────────────────────────────────────────
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        height: 1.29,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 1.33,
      ),

      // ── Title ────────────────────────────────────────────────────────────
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        height: 1.27,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.15,
        height: 1.5,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.43,
      ),

      // ── Label ────────────────────────────────────────────────────────────
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.33,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        height: 1.45,
      ),

      // ── Body ─────────────────────────────────────────────────────────────
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.15,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.25,
        height: 1.43,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
        height: 1.33,
      ),
    );
  }

  // ── Semantic Convenience Getters ──────────────────────────────────────────

  /// Large numeric value displayed on stat cards.
  static TextStyle get statValue => GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.0,
      );

  /// Compact numeric value on smaller stat cards.
  static TextStyle get statValueSmall => GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.25,
        height: 1.0,
      );

  /// Label on a badge / chip.
  static TextStyle get badgeLabel => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.4,
      );

  /// Monospace-like style for UUIDs / codes.
  static TextStyle get monoCode => GoogleFonts.jetBrainsMono(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.0,
      );

  /// Button label style — matched to labelLarge.
  static TextStyle get buttonLabel => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      );
}
