import 'package:flutter/material.dart';

import '../../../../core/theme/spacing.dart';
import '../../domain/enums/meal_type.dart';

class MealCard extends StatelessWidget {
  final MealType type;
  final IconData icon;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const MealCard({
    super.key,
    required this.type,
    required this.icon,
    required this.subtitle,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bgColor = isSelected
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.surface;
    final borderColor = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant;
    final elevation = isSelected ? 4.0 : 2.0;

    return AnimatedScale(
      scale: isSelected ? 1.03 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: elevation,
        color: bgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusLg),
          side: BorderSide(color: borderColor, width: isSelected ? 2 : 1),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Spacing.radiusLg),
          hoverColor: theme.colorScheme.primaryContainer.withAlpha(60),
          child: Semantics(
            button: true,
            label: 'Sélectionner ${type.label}',
            selected: isSelected,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: Spacing.xl,
                horizontal: Spacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 48, color: theme.colorScheme.primary),
                  const SizedBox(height: Spacing.sm),
                  Text(
                    type.label,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: Spacing.xxs),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
