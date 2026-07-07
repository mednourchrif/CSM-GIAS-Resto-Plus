import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/spacing.dart';
import '../../domain/enums/admin_section.dart';

/// Admin navigation drawer for mobile/tablet layouts.
///
/// Fixed the Spacer-inside-ListView bug by using a footer column instead.
class AdminDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final VoidCallback onLogout;

  const AdminDrawer({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sections = AdminSection.values;
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      child: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              Spacing.lg,
              MediaQuery.of(context).padding.top + Spacing.lg,
              Spacing.lg,
              Spacing.lg,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        AppColors.primaryContainerDark,
                        AppColors.surfaceContainerDark,
                      ]
                    : [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.75),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(Spacing.radiusMd),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu_rounded,
                    size: 26,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: Spacing.md),
                Text(
                  'CSM-GIAS Resto+',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: Spacing.xxs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.sm,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(Spacing.radiusFull),
                  ),
                  child: Text(
                    'Administration',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Navigation Items ─────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                vertical: Spacing.sm,
                horizontal: Spacing.xs,
              ),
              children: [
                // Dashboard
                _DrawerItem(
                  icon: Icons.dashboard_rounded,
                  label: 'Tableau de bord',
                  isSelected: selectedIndex == -1,
                  onTap: () {
                    onDestinationSelected(-1);
                    Navigator.of(context).pop();
                  },
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.md,
                    vertical: Spacing.xs,
                  ),
                  child: Text(
                    'GESTION',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                      letterSpacing: 1.0,
                    ),
                  ),
                ),

                // Sections 0-4 (management)
                for (int i = 0; i < sections.length; i++)
                  _DrawerItem(
                    icon: sections[i].icon,
                    label: sections[i].label,
                    isSelected: selectedIndex == i,
                    onTap: () {
                      onDestinationSelected(i);
                      Navigator.of(context).pop();
                    },
                  ),
              ],
            ),
          ),

          // ── Footer — Logout ───────────────────────────────────────────────
          Divider(
            height: 1,
            color: theme.colorScheme.outlineVariant,
          ),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.xxs,
            ),
            leading: Icon(
              Icons.logout_rounded,
              color: theme.colorScheme.error,
              size: Spacing.iconSm,
            ),
            title: Text(
              'Déconnexion',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: onLogout,
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + Spacing.xs),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.xxs),
      child: Material(
        color: isSelected
            ? theme.colorScheme.primaryContainer
            : Colors.transparent,
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Spacing.radiusMd),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.sm + 2,
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: AppDurations.fast,
                  child: Icon(
                    icon,
                    size: Spacing.iconSm,
                    color: isSelected
                        ? theme.colorScheme.onPrimaryContainer
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: Spacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? theme.colorScheme.onPrimaryContainer
                          : theme.colorScheme.onSurface,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(Spacing.radiusFull),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
