import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/spacing.dart';
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
            const SizedBox(height: Spacing.md),
            Tooltip(
              message: 'CSM-GIAS Resto+',
              child: Container(
                width: extended ? 142 : 54,
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(Spacing.radiusMd),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Image.asset(
                  'assets/branding/csm-gias.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
            if (extended) ...[
              const SizedBox(height: Spacing.sm),
              Text(
                'Administration Resto+',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
            const SizedBox(height: Spacing.md),
          ],
        ),
        destinations: [
          // Index 0 → dashboard (-1 + 1 = 0 in DashboardScreen)
          NavigationRailDestination(
            icon: Tooltip(
              message: extended ? '' : 'Tableau de bord',
              child: const Icon(Icons.dashboard_rounded),
            ),
            label: const Text('Tableau de bord'),
          ),
          for (final section in sections)
            NavigationRailDestination(
              icon: Tooltip(
                message: extended ? '' : section.label,
                child: Icon(section.icon),
              ),
              label: Text(section.label),
            ),
        ],
      ),
    );
  }
}
