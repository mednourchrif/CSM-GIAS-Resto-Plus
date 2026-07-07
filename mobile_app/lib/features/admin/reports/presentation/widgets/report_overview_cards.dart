import 'package:flutter/material.dart';

import '../../domain/entities/report_entity.dart';

class ReportOverviewCards extends StatelessWidget {
  final ReportOverview overview;

  const ReportOverviewCards({super.key, required this.overview});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600 ? 2 : (screenWidth < 900 ? 3 : 4);

    final cards = [
      _StatCard(
        icon: Icons.restaurant_rounded,
        label: 'Repas servis',
        value: overview.totalMeals.toString(),
        color: theme.colorScheme.primary,
      ),
      _StatCard(
        icon: Icons.people_rounded,
        label: 'Employés',
        value: overview.totalEmployees.toString(),
        color: theme.colorScheme.secondary,
      ),
      _StatCard(
        icon: Icons.school_rounded,
        label: 'Stagiaires',
        value: overview.totalInterns.toString(),
        color: theme.colorScheme.tertiary,
      ),
      _StatCard(
        icon: Icons.group_rounded,
        label: 'Visiteurs',
        value: overview.totalVisitors.toString(),
        color: Colors.green,
      ),
      _StatCard(
        icon: Icons.qr_code_rounded,
        label: 'QR Code',
        value: overview.qrRegistrations.toString(),
        color: Colors.purple,
      ),
      _StatCard(
        icon: Icons.face_rounded,
        label: 'Reconnaissance',
        value: overview.faceRegistrations.toString(),
        color: Colors.orange,
      ),
    ];

    if (overview.peakHour != null) {
      cards.add(_StatCard(
        icon: Icons.access_time_rounded,
        label: 'Heure de pointe',
        value: overview.peakHour!,
        color: Colors.indigo,
      ));
    }

    if (overview.mostSelectedMeal != null) {
      cards.add(_StatCard(
        icon: Icons.star_rounded,
        label: 'Repas le plus choisi',
        value: overview.mostSelectedMeal!,
        color: Colors.amber,
      ));
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      itemBuilder: (context, index) => cards[index],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
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
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
