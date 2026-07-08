import 'package:flutter/material.dart';

import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/spacing.dart';
import '../../../../../shared/widgets/shimmer_loading.dart';
import '../../domain/entities/meal_history.dart';

class MealHistoryStats extends StatelessWidget {
  final MealStats? stats;
  final bool isLoading;

  const MealHistoryStats({super.key, this.stats, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 900 ? 6 : 3;
          return ShimmerStatGrid(count: crossAxisCount);
        },
      );
    }

    if (stats == null) return const SizedBox.shrink();

    final cards = [
      _StatCard(
        label: 'Total repas',
        value: stats!.totalMeals.toString(),
        icon: Icons.restaurant,
        color: theme.colorScheme.primary,
      ),
      _StatCard(
        label: 'Employés',
        value: stats!.totalEmployees.toString(),
        icon: Icons.badge,
        color: AppColors.chartColors[0],
      ),
      _StatCard(
        label: 'Stagiaires',
        value: stats!.totalInterns.toString(),
        icon: Icons.school,
        color: AppColors.chartColors[1],
      ),
      _StatCard(
        label: 'Visiteurs',
        value: stats!.totalVisitors.toString(),
        icon: Icons.people,
        color: AppColors.chartColors[2],
      ),
      _StatCard(
        label: 'Visage',
        value: stats!.faceRegistrations.toString(),
        icon: Icons.face,
        color: AppColors.chartColors[3],
      ),
      _StatCard(
        label: 'QR Code',
        value: stats!.qrRegistrations.toString(),
        icon: Icons.qr_code,
        color: AppColors.chartColors[4],
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900 ? 6 : 3;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisExtent: 145,
            crossAxisSpacing: Spacing.sm,
            mainAxisSpacing: Spacing.sm,
          ),
          itemCount: cards.length,
          itemBuilder: (_, i) => cards[i],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: Spacing.iconSm, color: color),
                const SizedBox(width: Spacing.xs),
                Flexible(
                  child: Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
