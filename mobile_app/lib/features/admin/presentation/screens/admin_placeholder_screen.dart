import 'package:flutter/material.dart';

import '../../../../core/theme/spacing.dart';
import '../../domain/enums/admin_section.dart';

class AdminPlaceholderScreen extends StatelessWidget {
  final AdminSection section;

  const AdminPlaceholderScreen({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(section.icon, size: 72, color: theme.colorScheme.primary),
            const SizedBox(height: Spacing.md),
            Text(
              section.placeholderTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Text(
              section.placeholderDescription,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
