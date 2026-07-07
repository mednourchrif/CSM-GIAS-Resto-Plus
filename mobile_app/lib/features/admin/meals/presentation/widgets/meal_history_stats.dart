import 'package:flutter/material.dart';

import '../../domain/entities/meal_history.dart';

class MealHistoryStats extends StatelessWidget {
  final MealStats? stats;
  final bool isLoading;

  const MealHistoryStats({super.key, this.stats, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return SizedBox(
        height: 100,
        child: Center(child: CircularProgressIndicator()),
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
        color: Colors.blue,
      ),
      _StatCard(
        label: 'Stagiaires',
        value: stats!.totalInterns.toString(),
        icon: Icons.school,
        color: Colors.orange,
      ),
      _StatCard(
        label: 'Visiteurs',
        value: stats!.totalVisitors.toString(),
        icon: Icons.people,
        color: Colors.purple,
      ),
      _StatCard(
        label: 'Visage',
        value: stats!.faceRegistrations.toString(),
        icon: Icons.face,
        color: Colors.green,
      ),
      _StatCard(
        label: 'QR Code',
        value: stats!.qrRegistrations.toString(),
        icon: Icons.qr_code,
        color: Colors.blue.shade700,
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
            childAspectRatio: 1.5,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
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
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 6),
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
            const Spacer(),
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
