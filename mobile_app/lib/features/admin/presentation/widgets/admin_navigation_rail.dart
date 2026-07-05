import 'package:flutter/material.dart';

import '../../../../core/theme/spacing.dart';
import '../../domain/enums/admin_section.dart';

class AdminNavigationRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const AdminNavigationRail({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final sections = AdminSection.values;

    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      labelType: NavigationRailLabelType.all,
      minExtendedWidth: 180,
      groupAlignment: 0,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
        child: Icon(
          Icons.restaurant_menu_rounded,
          size: 32,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
      destinations: [
        const NavigationRailDestination(
          icon: Icon(Icons.dashboard_rounded),
          label: Text('Tableau de bord'),
        ),
        for (final section in sections)
          NavigationRailDestination(
            icon: Icon(section.icon),
            label: Text(section.label),
          ),
      ],
    );
  }
}
