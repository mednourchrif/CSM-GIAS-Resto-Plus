import 'package:flutter/material.dart';
import 'colors.dart';
import 'spacing.dart';
import 'typography.dart';

/// Complete Material 3 theme for CSM-GIAS Resto+.
///
/// Every component theme is explicitly defined to avoid relying on
/// Material defaults. All values reference design tokens from [AppColors],
/// [Spacing], and [AppTypography].
class AppTheme {
  AppTheme._();

  // ─── Light Theme ──────────────────────────────────────────────────────────
  static ThemeData get light => _buildTheme(_lightColorScheme);

  // ─── Dark Theme ───────────────────────────────────────────────────────────
  static ThemeData get dark => _buildTheme(_darkColorScheme);

  // ─── Color Schemes ────────────────────────────────────────────────────────

  static final ColorScheme _lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.primaryContainer,
    onPrimaryContainer: AppColors.onPrimaryContainer,
    secondary: AppColors.secondary,
    onSecondary: AppColors.onSecondary,
    secondaryContainer: AppColors.secondaryContainer,
    onSecondaryContainer: AppColors.onSecondaryContainer,
    tertiary: AppColors.tertiary,
    onTertiary: AppColors.onTertiary,
    tertiaryContainer: AppColors.tertiaryContainer,
    onTertiaryContainer: AppColors.onTertiaryContainer,
    error: AppColors.error,
    onError: AppColors.onError,
    errorContainer: AppColors.errorContainer,
    onErrorContainer: AppColors.onErrorContainer,
    surface: AppColors.surfaceLight,
    onSurface: AppColors.onSurfaceLight,
    surfaceContainerHighest: AppColors.surfaceContainerHighestLight,
    onSurfaceVariant: AppColors.onSurfaceVariantLight,
    outline: AppColors.outlineLight,
    outlineVariant: AppColors.outlineVariantLight,
    scrim: AppColors.scrim,
    inverseSurface: AppColors.onSurfaceLight,
    onInverseSurface: AppColors.surfaceLight,
    inversePrimary: AppColors.primaryContainer,
    surfaceTint: AppColors.primary,
  );

  static final ColorScheme _darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primaryDark,
    onPrimary: AppColors.onPrimaryDark,
    primaryContainer: AppColors.primaryContainerDark,
    onPrimaryContainer: AppColors.onPrimaryContainerDark,
    secondary: AppColors.secondaryDark,
    onSecondary: AppColors.onSecondaryDark,
    secondaryContainer: AppColors.secondaryContainerDark,
    onSecondaryContainer: AppColors.onSecondaryContainerDark,
    tertiary: AppColors.tertiaryDark,
    onTertiary: AppColors.onTertiaryDark,
    tertiaryContainer: AppColors.tertiaryContainerDark,
    onTertiaryContainer: AppColors.onTertiaryContainerDark,
    error: AppColors.errorDark,
    onError: AppColors.onErrorDark,
    errorContainer: AppColors.errorContainerDark,
    onErrorContainer: AppColors.onErrorContainerDark,
    surface: AppColors.surfaceDark,
    onSurface: AppColors.onSurfaceDark,
    surfaceContainerHighest: AppColors.surfaceContainerHighestDark,
    onSurfaceVariant: AppColors.onSurfaceVariantDark,
    outline: AppColors.outlineDark,
    outlineVariant: AppColors.outlineVariantDark,
    scrim: AppColors.scrim,
    inverseSurface: AppColors.onSurfaceDark,
    onInverseSurface: AppColors.surfaceDark,
    inversePrimary: AppColors.primaryContainerDark,
    surfaceTint: AppColors.primaryDark,
  );

  // ─── Theme Builder ────────────────────────────────────────────────────────

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    final textTheme = AppTypography.textTheme;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      brightness: colorScheme.brightness,

      // ── Scaffold ──────────────────────────────────────────────────────────
      scaffoldBackgroundColor: colorScheme.surface,

      // ── AppBar ────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(
          color: colorScheme.onSurfaceVariant,
          size: Spacing.iconMd,
        ),
        actionsIconTheme: IconThemeData(
          color: colorScheme.onSurfaceVariant,
          size: Spacing.iconMd,
        ),
        shape: Border(
          bottom: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),

      // ── Card ──────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark
            ? AppColors.surfaceContainerDark
            : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusMd),
          side: BorderSide(
            color: colorScheme.outlineVariant,
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        margin: EdgeInsets.zero,
      ),

      // ── Filled Button ─────────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, Spacing.minTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg,
            vertical: Spacing.sm + 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Spacing.radiusMd),
          ),
          textStyle: textTheme.labelLarge,
          elevation: 0,
        ),
      ),

      // ── Outlined Button ───────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, Spacing.minTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg,
            vertical: Spacing.sm + 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Spacing.radiusMd),
          ),
          textStyle: textTheme.labelLarge,
          side: BorderSide(color: colorScheme.outline),
        ),
      ),

      // ── Text Button ───────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(0, Spacing.minTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.xs,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Spacing.radiusSm),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // ── Elevated Button ───────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(0, Spacing.minTouchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.lg,
            vertical: Spacing.sm + 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Spacing.radiusMd),
          ),
          textStyle: textTheme.labelLarge,
          elevation: Spacing.elevationSm,
        ),
      ),

      // ── Icon Button ───────────────────────────────────────────────────────
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size(Spacing.minTouchTarget, Spacing.minTouchTarget),
          iconSize: Spacing.iconMd,
        ),
      ),

      // ── FAB ───────────────────────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: Spacing.elevationMd,
        highlightElevation: Spacing.elevationLg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusLg),
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),

      // ── Input Decoration ─────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark
            ? AppColors.surfaceContainerHighestDark.withValues(alpha: 0.5)
            : AppColors.surfaceContainerLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusMd),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusMd),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusMd),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusMd),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusMd),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusMd),
          borderSide: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm + 4,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        floatingLabelStyle: textTheme.bodySmall?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w600,
        ),
        errorStyle: textTheme.bodySmall?.copyWith(
          color: colorScheme.error,
        ),
        prefixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.focused)) {
            return colorScheme.primary;
          }
          return colorScheme.onSurfaceVariant;
        }),
        suffixIconColor: colorScheme.onSurfaceVariant,
      ),

      // ── SnackBar ──────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusMd),
        ),
        elevation: Spacing.elevationMd,
        backgroundColor: isDark
            ? const Color(0xFF2A3038)
            : const Color(0xFF1F2428),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: Colors.white,
        ),
        actionTextColor: AppColors.primaryContainer,
      ),

      // ── Dialog ────────────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        elevation: Spacing.elevationXl,
        backgroundColor: isDark
            ? AppColors.surfaceContainerDark
            : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusXl),
        ),
        titleTextStyle: textTheme.headlineSmall?.copyWith(
          color: colorScheme.onSurface,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.xxl,
        ),
      ),

      // ── Bottom Sheet ──────────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        showDragHandle: true,
        elevation: Spacing.elevationLg,
        backgroundColor: isDark
            ? AppColors.surfaceContainerDark
            : Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(Spacing.radiusXl),
          ),
        ),
        dragHandleColor: colorScheme.outlineVariant,
        dragHandleSize: const Size(32, 4),
      ),

      // ── Chip ──────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        labelStyle: textTheme.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusSm),
        ),
        side: BorderSide(color: colorScheme.outlineVariant),
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.xs,
        ),
        elevation: 0,
        pressElevation: 0,
        checkmarkColor: colorScheme.primary,
        selectedColor: colorScheme.primaryContainer,
        backgroundColor: colorScheme.surface,
      ),

      // ── List Tile ─────────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.xs,
        ),
        minLeadingWidth: Spacing.iconMd,
        minVerticalPadding: Spacing.sm,
        style: ListTileStyle.list,
        titleTextStyle: textTheme.bodyLarge,
        subtitleTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // ── Divider ───────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // ── Navigation Rail ───────────────────────────────────────────────────
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: isDark
            ? AppColors.surfaceContainerDark
            : const Color(0xFFF0F4F8),
        selectedIconTheme: IconThemeData(
          color: colorScheme.onPrimaryContainer,
          size: Spacing.iconMd,
        ),
        unselectedIconTheme: IconThemeData(
          color: colorScheme.onSurfaceVariant,
          size: Spacing.iconMd,
        ),
        selectedLabelTextStyle: textTheme.labelSmall?.copyWith(
          color: colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelTextStyle: textTheme.labelSmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        indicatorColor: colorScheme.primaryContainer,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusMd),
        ),
        elevation: 0,
        groupAlignment: -1,
        labelType: NavigationRailLabelType.all,
        minWidth: 72,
        minExtendedWidth: 196,
      ),

      // ── Navigation Drawer ─────────────────────────────────────────────────
      drawerTheme: DrawerThemeData(
        backgroundColor: isDark
            ? AppColors.surfaceContainerDark
            : const Color(0xFFF5F7FA),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(
            right: Radius.circular(Spacing.radiusXl),
          ),
        ),
        width: 280,
      ),

      // ── Data Table ────────────────────────────────────────────────────────
      dataTableTheme: DataTableThemeData(
        headingRowColor: WidgetStateProperty.all(
          isDark
              ? AppColors.surfaceContainerHighestDark
              : AppColors.surfaceContainerLight,
        ),
        dataRowColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return colorScheme.primary.withValues(alpha: 0.06);
          }
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primaryContainer.withValues(alpha: 0.3);
          }
          return null;
        }),
        headingTextStyle: textTheme.labelMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
        dataTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
        headingRowHeight: 52,
        dataRowMinHeight: 52,
        dataRowMaxHeight: 68,
        dividerThickness: 1,
        horizontalMargin: Spacing.md,
        columnSpacing: Spacing.lg,
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(Spacing.radiusMd),
        ),
      ),

      // ── Progress Indicator ────────────────────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        linearTrackColor: colorScheme.primary.withValues(alpha: 0.15),
        linearMinHeight: 4,
        circularTrackColor: colorScheme.primary.withValues(alpha: 0.15),
      ),

      // ── Badge ─────────────────────────────────────────────────────────────
      badgeTheme: BadgeThemeData(
        backgroundColor: colorScheme.error,
        textColor: colorScheme.onError,
        textStyle: AppTypography.badgeLabel,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        smallSize: 8,
        largeSize: 16,
      ),

      // ── Tooltip ───────────────────────────────────────────────────────────
      tooltipTheme: TooltipThemeData(
        textStyle: textTheme.bodySmall?.copyWith(
          color: Colors.white,
        ),
        decoration: BoxDecoration(
          color: colorScheme.onSurface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(Spacing.radiusSm),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm + 4,
          vertical: Spacing.xs + 2,
        ),
        waitDuration: const Duration(milliseconds: 500),
      ),

      // ── Page Transitions ─────────────────────────────────────────────────
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.fuchsia: FadeUpwardsPageTransitionsBuilder(),
        },
      ),

      // ── Popup Menu ────────────────────────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        color: isDark ? AppColors.surfaceContainerDark : Colors.white,
        elevation: Spacing.elevationMd,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusMd),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        labelTextStyle: WidgetStateProperty.all(textTheme.bodyMedium),
        textStyle: textTheme.bodyMedium,
      ),

      // ── Switch ────────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.onPrimary;
          }
          return colorScheme.outline;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.surfaceContainerHighest;
        }),
      ),

      // ── Checkbox ─────────────────────────────────────────────────────────
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(colorScheme.onPrimary),
        side: BorderSide(color: colorScheme.outline, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // ── Radio ─────────────────────────────────────────────────────────────
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.outline;
        }),
      ),
    );
  }
}
