import 'package:flutter/material.dart';

import '../../../../core/localization/app_strings.dart';
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
    final strings = AppStrings.of(context);
    final mealLabel = strings.mealLabel(type);
    final mealSubtitle = subtitle.isEmpty
        ? strings.mealSubtitle(type)
        : subtitle;

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
          border: Border.all(color: borderColor, width: isSelected ? 2.0 : 1.0),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
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
            hoverColor: theme.colorScheme.primaryContainer.withValues(
              alpha: 0.5,
            ),
            child: Semantics(
              button: true,
              label: '${strings.confirm} $mealLabel',
              selected: isSelected,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final horizontal =
                      constraints.maxWidth >= 300 && constraints.maxWidth < 520;
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: horizontal ? Spacing.md : Spacing.xl,
                      horizontal: Spacing.lg,
                    ),
                    child: horizontal
                        ? Row(
                            children: [
                              _iconTile(theme, 56),
                              const SizedBox(width: Spacing.md),
                              Expanded(
                                child: _labels(
                                  theme,
                                  TextAlign.start,
                                  mealLabel,
                                  mealSubtitle,
                                ),
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: Spacing.sm),
                                Icon(
                                  Icons.check_circle_rounded,
                                  size: Spacing.iconSm,
                                  color: theme.colorScheme.primary,
                                ),
                              ],
                            ],
                          )
                        : Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _iconTile(theme, 64),
                              const SizedBox(height: Spacing.md),
                              _labels(
                                theme,
                                TextAlign.center,
                                mealLabel,
                                mealSubtitle,
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
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconTile(ThemeData theme, double size) {
    return AnimatedContainer(
      duration: AppDurations.fast,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.primaryContainer.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
      ),
      child: Icon(
        icon,
        size: Spacing.iconLg,
        color: isSelected
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.primary,
      ),
    );
  }

  Widget _labels(
    ThemeData theme,
    TextAlign alignment,
    String mealLabel,
    String mealSubtitle,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignment == TextAlign.start
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Text(
          mealLabel,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
          ),
          textAlign: alignment,
        ),
        const SizedBox(height: Spacing.xxs),
        Text(
          mealSubtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: alignment,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
