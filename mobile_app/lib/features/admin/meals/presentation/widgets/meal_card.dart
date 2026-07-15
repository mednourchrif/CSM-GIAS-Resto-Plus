import 'package:flutter/material.dart';

import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/spacing.dart';
import '../../domain/entities/meal_history.dart';
import 'meal_detail_screen.dart';
import 'meal_status_badge.dart';

class MealCard extends StatelessWidget {
  final MealHistory meal;
  final ThemeData theme;
  final VoidCallback? onTap;

  const MealCard({required this.meal, required this.theme, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap ?? () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MealDetailScreen(meal: meal),
            ),
          );
        },
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: meal.isFace
                    ? AppColors.success.withValues(alpha: 0.15)
                    : AppColors.info.withValues(alpha: 0.15),
                child: Icon(
                  meal.isFace ? Icons.face : Icons.qr_code,
                  color: meal.isFace ? AppColors.success : AppColors.info,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.displayName.isNotEmpty ? meal.displayName : meal.utilisateurUuid,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: Spacing.xxs),
                    Wrap(
                      spacing: Spacing.xs,
                      runSpacing: Spacing.xxs,
                      children: [
                        Text(
                          '${meal.dateRepas.day.toString().padLeft(2, '0')}/'
                          '${meal.dateRepas.month.toString().padLeft(2, '0')}/'
                          '${meal.dateRepas.year}',
                          style: theme.textTheme.bodySmall,
                        ),
                        Text(
                          meal.heureRepas,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (meal.categorieNom != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(Spacing.radiusSm),
                            ),
                            child: Text(
                              meal.categorieNom!,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                        MealStatusBadge(type: meal.typeIdentification),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
