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

    return AnimatedScale(
      scale: isSelected ? 1.03 : 1.0,
      duration: AppDurations.fast,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        curve: AppCurves.enter,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(Spacing.radiusLg),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  const BoxShadow(
                    color: Color(0x08000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(Spacing.radiusLg),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(Spacing.radiusLg),
            splashColor: theme.colorScheme.primary.withValues(alpha: 0.12),
            highlightColor: theme.colorScheme.primary.withValues(alpha: 0.06),
            hoverColor: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
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
                    // Icon with animated background
                    AnimatedContainer(
                      duration: AppDurations.fast,
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(Spacing.radiusMd),
                      ),
                      child: Icon(
                        icon,
                        size: Spacing.iconLg,
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: Spacing.md),
                    Text(
                      type.label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: Spacing.xxs),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isSelected) ...[
                      const SizedBox(height: Spacing.sm),
                      Icon(
                        Icons.check_circle_rounded,
                        size: Spacing.iconSm,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
