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
    final sections = AdminSection.values;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceContainerDark
            : const Color(0xFFF0F4F8),
        border: Border(
          right: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(Spacing.radiusMd),
                ),
                child: const Icon(
                  Icons.restaurant_menu_rounded,
                  size: 22,
                  color: Colors.white,
                ),
              ),
            ),
            if (extended) ...[
              const SizedBox(height: Spacing.sm),
              Text(
                'CSM-GIAS',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
            const SizedBox(height: Spacing.md),
          ],
        ),
        trailing: null,
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
