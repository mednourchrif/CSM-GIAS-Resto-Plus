import 'package:flutter/material.dart';

import '../../../../core/theme/spacing.dart';
import '../../domain/enums/admin_section.dart';

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

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.restaurant_menu_rounded,
                  size: 40,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(height: Spacing.sm),
                Text(
                  'CSM-GIAS Resto+',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                Text(
                  'Administration',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_rounded),
            title: const Text('Tableau de bord'),
            selected: selectedIndex == -1,
            onTap: () => onDestinationSelected(-1),
          ),
          const Divider(),
          for (int i = 0; i < sections.length; i++) ...[
            ListTile(
              leading: Icon(sections[i].icon),
              title: Text(sections[i].label),
              selected: selectedIndex == i,
              onTap: () => onDestinationSelected(i),
            ),
          ],
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text('Déconnexion'),
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}
