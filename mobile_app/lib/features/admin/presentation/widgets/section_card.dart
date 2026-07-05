import 'package:flutter/material.dart';

import '../../../../core/theme/spacing.dart';
import '../../domain/enums/admin_section.dart';

class SectionCard extends StatelessWidget {
  final AdminSection section;
  final VoidCallback onTap;

  const SectionCard({
    super.key,
    required this.section,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(section.icon, size: 40, color: theme.colorScheme.primary),
              const SizedBox(height: Spacing.sm),
              Text(
                section.label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
