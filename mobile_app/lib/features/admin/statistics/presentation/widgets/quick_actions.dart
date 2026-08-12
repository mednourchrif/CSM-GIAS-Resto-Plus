import 'package:flutter/material.dart';

import '../../../../../core/theme/spacing.dart';

class QuickActions extends StatelessWidget {
  final void Function(int index) onSectionTap;
  const QuickActions({super.key, required this.onSectionTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actions = [
      const _ActionItem(
        icon: Icons.people_rounded,
        label: 'Employés',
        index: 0,
      ),
      const _ActionItem(
        icon: Icons.school_rounded,
        label: 'Stagiaires',
        index: 1,
      ),
      const _ActionItem(
        icon: Icons.group_rounded,
        label: 'Visiteurs',
        index: 2,
      ),
      const _ActionItem(
        icon: Icons.qr_code_rounded,
        label: 'QR Codes',
        index: 3,
      ),
      const _ActionItem(
        icon: Icons.restaurant_menu_rounded,
        label: 'Repas',
        index: 5,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width >= 720 ? 3 : 2;
        final childAspectRatio = width >= 720 ? 3.2 : 2.8;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          mainAxisSpacing: Spacing.sm,
          crossAxisSpacing: Spacing.sm,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: actions.map((a) {
            return InkWell(
              onTap: () => onSectionTap(a.index),
              borderRadius: BorderRadius.circular(Spacing.radiusMd),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.sm,
                  vertical: Spacing.sm,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Spacing.radiusMd),
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(a.icon, size: 20, color: theme.colorScheme.primary),
                    const SizedBox(width: Spacing.sm),
                    Flexible(
                      child: Text(
                        a.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
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
