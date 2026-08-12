import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/spacing.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../shared/widgets/brand_logo.dart';
import '../../domain/enums/admin_section.dart';

/// Admin navigation rail for tablet/desktop layouts.
class AdminNavigationRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool extended;

  const AdminNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.extended = false,
  });

  @override
  Widget build(BuildContext context) {
    const sections = AdminSection.values;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final strings = AppStrings.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceContainerDark
            : const Color(0xFFF0F4F8),
        border: Border(
          right: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
      child: NavigationRail(
        extended: extended,
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        labelType: extended
            ? NavigationRailLabelType.none
            : NavigationRailLabelType.all,
        minWidth: 72,
        minExtendedWidth: 196,
        backgroundColor: Colors.transparent,
        groupAlignment: -1,
        leading: Column(
          children: [
            const SizedBox(height: Spacing.sm),
            Container(
              width: extended ? 150 : 52,
              height: extended ? 52 : 44,
              padding: EdgeInsets.symmetric(
                horizontal: extended ? Spacing.xs : 2,
                vertical: 1,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(Spacing.radiusLg),
                border: Border.all(color: theme.colorScheme.outlineVariant),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Tooltip(
                message: 'CSM-GIAS Resto+',
                child: FittedBox(child: BrandLogo(width: 128, framed: false)),
              ),
            ),
            if (extended) ...[
              const SizedBox(height: Spacing.xs),
              Text(
                '${strings.administration} Resto+',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
            const SizedBox(height: Spacing.xs),
          ],
        ),
        destinations: [
          // Index 0 → dashboard (-1 + 1 = 0 in DashboardScreen)
          NavigationRailDestination(
            icon: Tooltip(
              message: extended ? '' : strings.dashboard,
              child: const Icon(Icons.dashboard_rounded),
            ),
            label: Text(strings.dashboard),
          ),
          for (final section in sections)
            NavigationRailDestination(
              icon: Tooltip(
                message: extended
                    ? ''
                    : strings.adminSectionLabel(section.name),
                child: Icon(section.icon),
              ),
              label: Text(strings.adminSectionLabel(section.name)),
            ),
        ],
      ),
    );
  }
}
