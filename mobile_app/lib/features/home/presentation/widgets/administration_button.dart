import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/spacing.dart';

class AdministrationButton extends StatelessWidget {
  const AdministrationButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton.icon(
      onPressed: () => context.push('/login'),
      icon: Icon(
        Icons.admin_panel_settings_outlined,
        size: Spacing.iconXs + 2,
        color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
      ),
      label: Text(
        'Administration',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.xs,
        ),
        minimumSize: const Size(0, Spacing.minTouchTarget),
      ),
    );
  }
}
