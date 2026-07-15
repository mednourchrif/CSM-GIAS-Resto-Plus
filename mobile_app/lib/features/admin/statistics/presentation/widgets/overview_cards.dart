import 'package:flutter/material.dart';

import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/spacing.dart';
import '../../domain/entities/dashboard_stats.dart';

class OverviewCards extends StatelessWidget {
  final DashboardStats stats;
  const OverviewCards({required this.stats});

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatCard(
        label: 'Repas aujourd\'hui',
        value: stats.mealsToday.toString(),
        icon: Icons.today_rounded,
        color: AppColors.success,
      ),
      _StatCard(
        label: 'Cette semaine',
        value: stats.mealsThisWeek.toString(),
        icon: Icons.calendar_view_week_rounded,
        color: AppColors.primary,
      ),
      _StatCard(
        label: 'Ce mois',
        value: stats.mealsThisMonth.toString(),
        icon: Icons.calendar_month_rounded,
        color: AppColors.info,
      ),
      _StatCard(
        label: 'Employés',
        value: stats.employees.toString(),
        icon: Icons.badge_rounded,
        color: AppColors.tertiary,
      ),
      _StatCard(
        label: 'Stagiaires',
        value: stats.interns.toString(),
        icon: Icons.school_rounded,
        color: AppColors.warning,
      ),
      _StatCard(
        label: 'Visiteurs',
        value: stats.visitors.toString(),
        icon: Icons.people_rounded,
        color: const Color(0xFF7B1FA2),
      ),
      _StatCard(
        label: 'QR aujourd\'hui',
        value: stats.qrToday.toString(),
        icon: Icons.qr_code_rounded,
        color: AppColors.info,
      ),
      _StatCard(
        label: 'Visage aujourd\'hui',
        value: stats.faceToday.toString(),
        icon: Icons.face_rounded,
        color: AppColors.success,
      ),
      _StatCard(
        label: 'QR codes actifs',
        value: stats.activeQrCodes.toString(),
        icon: Icons.check_circle_rounded,
        color: AppColors.success,
      ),
      _StatCard(
        label: 'QR codes expirés',
        value: stats.expiredQrCodes.toString(),
        icon: Icons.timer_off_rounded,
        color: AppColors.error,
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 900
            ? 5
            : constraints.maxWidth > 600
                ? 4
                : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: 1.6,
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
      child: Padding(
        padding: const EdgeInsets.all(Spacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(Spacing.radiusSm),
                  ),
                  child: Icon(icon, size: 15, color: color),
                ),
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
            const Spacer(),
            TweenAnimationBuilder<int>(
              tween: IntTween(begin: 0, end: int.tryParse(value) ?? 0),
              duration: AppDurations.slowest,
              curve: Curves.easeOutCubic,
              builder: (_, v, __) => Text(
                v.toString(),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
