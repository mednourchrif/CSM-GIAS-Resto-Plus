import 'package:flutter/material.dart';

import '../../../../../core/theme/spacing.dart';
import '../../domain/entities/meal_history.dart';
import 'meal_status_badge.dart';

class MealDetailScreen extends StatelessWidget {
  final MealHistory meal;

  const MealDetailScreen({required this.meal});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Détail du repas')),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.md),
        children: [
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(Spacing.radiusMd),
              side: BorderSide(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow(label: 'UUID', value: meal.uuid, theme: theme),
                  const Divider(),
                  _DetailRow(
                    label: 'Utilisateur',
                    value: meal.displayName.isNotEmpty
                        ? meal.displayName
                        : 'N/A',
                    theme: theme,
                  ),
                  const Divider(),
                  _DetailRow(label: 'Email', value: meal.email ?? 'N/A', theme: theme),
                  const Divider(),
                  _DetailRow(label: 'UUID Utilisateur', value: meal.utilisateurUuid, theme: theme),
                  const Divider(),
                  _DetailRow(
                    label: 'Date',
                    value:
                        '${meal.dateRepas.day.toString().padLeft(2, '0')}/'
                        '${meal.dateRepas.month.toString().padLeft(2, '0')}/'
                        '${meal.dateRepas.year}',
                    theme: theme,
                  ),
                  const Divider(),
                  _DetailRow(label: 'Heure', value: meal.heureRepas, theme: theme),
                  const Divider(),
                  _DetailRow(label: 'Catégorie', value: meal.categorieNom ?? 'N/A', theme: theme),
                  const Divider(),
                  Wrap(
                    spacing: Spacing.sm,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Type d\'identification',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      MealStatusBadge(type: meal.typeIdentification),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final ThemeData theme;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
