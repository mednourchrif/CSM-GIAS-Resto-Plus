import 'package:flutter/material.dart';

import '../../../../../core/theme/spacing.dart';

class QuickActions extends StatelessWidget {
  final void Function(int index) onSectionTap;
  const QuickActions({required this.onSectionTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actions = [
      _ActionItem(icon: Icons.people_rounded, label: 'Employés', index: 0),
      _ActionItem(icon: Icons.school_rounded, label: 'Stagiaires', index: 1),
      _ActionItem(icon: Icons.group_rounded, label: 'Visiteurs', index: 2),
      _ActionItem(icon: Icons.qr_code_rounded, label: 'QR Codes', index: 3),
      _ActionItem(icon: Icons.restaurant_menu_rounded, label: 'Repas', index: 5),
    ];

    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 2,
      mainAxisSpacing: Spacing.sm,
      crossAxisSpacing: Spacing.sm,
      physics: const NeverScrollableScrollPhysics(),
      children: actions.map((a) {
        return InkWell(
          onTap: () => onSectionTap(a.index),
          borderRadius: BorderRadius.circular(Spacing.radiusMd),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Spacing.radiusMd),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(a.icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: Spacing.sm),
                Text(a.label,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final int index;
  const _ActionItem({
    required this.icon,
    required this.label,
    required this.index,
  });
}
