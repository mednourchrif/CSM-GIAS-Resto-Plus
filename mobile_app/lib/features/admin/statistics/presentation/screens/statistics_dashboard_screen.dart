import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/spacing.dart';
import '../../../../../shared/widgets/error_state.dart';
import '../../../../../shared/widgets/shimmer_loading.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../providers/statistics_provider.dart';
import '../providers/statistics_state.dart';

class StatisticsDashboardScreen extends ConsumerStatefulWidget {
  final void Function(int index)? onSectionTap;

  const StatisticsDashboardScreen({super.key, this.onSectionTap});

  @override
  ConsumerState<StatisticsDashboardScreen> createState() =>
      _StatisticsDashboardScreenState();
}

class _StatisticsDashboardScreenState
    extends ConsumerState<StatisticsDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(statisticsProvider.notifier).load(),
    );
  }

  Future<void> _onRefresh() async {
    await ref.read(statisticsProvider.notifier).load();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(statisticsProvider);
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: _buildBody(state, theme, isDesktop),
    );
  }

  Widget _buildBody(StatisticsState state, ThemeData theme, bool isDesktop) {
    if (state.isLoading && state.stats == null) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          children: [
            const ShimmerStatGrid(count: 10),
            const SizedBox(height: Spacing.md),
            ShimmerCard(height: isDesktop ? 320 : 280),
            ShimmerCard(height: 280),
          ],
        ),
      );
    }

    if (state.error != null && state.stats == null) {
      return ErrorState(
        message: state.error!,
        icon: Icons.bar_chart_outlined,
        onRetry: _onRefresh,
      );
    }

    final stats = state.stats;
    if (stats == null) {
      return const Center(child: Text('Aucune donnée'));
    }

    return ListView(
      padding: const EdgeInsets.all(Spacing.md),
      children: [
        // Overview Cards
        _OverviewCards(stats: stats),

        const SizedBox(height: Spacing.md),

        if (isDesktop) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _Card(
                  title: 'Repas par jour (cette semaine)',
                  child: SizedBox(
                    height: 280,
                    child: _MealsPerDayChart(items: stats.mealsPerDay),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                flex: 2,
                child: _Card(
                  title: 'Distribution des repas',
                  child: SizedBox(
                    height: 280,
                    child:
                        _DonutChart(items: stats.mealDistribution),
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          _Card(
            title: 'Repas par jour (cette semaine)',
            child: SizedBox(
              height: 260,
              child: _MealsPerDayChart(items: stats.mealsPerDay),
            ),
          ),
          _Card(
            title: 'Distribution des repas',
            child: SizedBox(
              height: 260,
              child: _DonutChart(items: stats.mealDistribution),
            ),
          ),
        ],

        const SizedBox(height: Spacing.md),

        if (isDesktop) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Card(
                  title: 'Type d\'utilisateur',
                  child: SizedBox(
                    height: 240,
                    child: _UserTypeChart(items: stats.userTypeDistribution),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: _Card(
                  title: 'Méthode d\'inscription',
                  child: SizedBox(
                    height: 240,
                    child: _RegistrationMethodChart(
                        items: stats.registrationMethods),
                  ),
                ),
              ),
              Expanded(
                child: _Card(
                  title: 'Heures d\'affluence',
                  child: SizedBox(
                    height: 240,
                    child: _PeakHoursChart(items: stats.peakHours),
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          _Card(
            title: 'Type d\'utilisateur',
            child: SizedBox(
              height: 240,
              child: _UserTypeChart(items: stats.userTypeDistribution),
            ),
          ),
          _Card(
            title: 'Méthode d\'inscription',
            child: SizedBox(
              height: 240,
              child: _RegistrationMethodChart(items: stats.registrationMethods),
            ),
          ),
          _Card(
            title: 'Heures d\'affluence',
            child: SizedBox(
              height: 240,
              child: _PeakHoursChart(items: stats.peakHours),
            ),
          ),
        ],

        const SizedBox(height: Spacing.md),

        if (isDesktop) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _Card(
                  title: 'Activité récente',
                  child: SizedBox(
                    height: 400,
                    child: _RecentActivity(items: stats.recentRegistrations),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                flex: 2,
                child: _Card(
                  title: 'Accès rapides',
                  child: SizedBox(
                    height: 240,
                    child: _QuickActions(onSectionTap: widget.onSectionTap ?? _navigateTo),
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          _Card(
            title: 'Activité récente',
            child: SizedBox(
              height: 360,
              child: _RecentActivity(items: stats.recentRegistrations),
            ),
          ),
          _Card(
            title: 'Accès rapides',
            child: SizedBox(
              height: 240,
              child: _QuickActions(onSectionTap: widget.onSectionTap ?? _navigateTo),
            ),
          ),
        ],
      ],
    );
  }

  void _navigateTo(int index) {
    Navigator.of(context).maybePop();
    // The parent DashboardScreen listens for index changes to switch sections.
  }
}

// =========================================================================
// Overview Cards
// =========================================================================

class _OverviewCards extends StatelessWidget {
  final DashboardStats stats;
  const _OverviewCards({required this.stats});

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

// =========================================================================
// Card wrapper
// =========================================================================

class _Card extends StatelessWidget {
  final String title;
  final Widget child;
  const _Card({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.md),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Spacing.radiusMd),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: Spacing.sm),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// Line Chart — Meals Per Day
// =========================================================================

class _MealsPerDayChart extends StatelessWidget {
  final List<MealCountByDate> items;
  const _MealsPerDayChart({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return _emptyText(context);
    final spots = items.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.count.toDouble());
    }).toList();

    final maxY = items.map((e) => e.count).reduce((a, b) => a > b ? a : b);
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: true, reservedSize: 32,
                getTitlesWidget: (v, _) =>
                    Text('${v.toInt()}', style: const TextStyle(fontSize: 10))),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: 1,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= items.length) return const SizedBox();
                final date = items[i].date;
                final parts = date.split('-');
                final label = parts.length >= 3
                    ? '${parts[2]}/${parts[1]}'
                    : date;
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(label, style: const TextStyle(fontSize: 9)),
                );
              },
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (items.length - 1).toDouble(),
        minY: 0,
        maxY: (maxY * 1.2).toDouble(),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            preventCurveOverShooting: true,
            color: Theme.of(context).colorScheme.primary,
            barWidth: 2.5,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                radius: 3,
                color: Theme.of(context).colorScheme.primary,
                strokeWidth: 1.5,
                strokeColor: Colors.white,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.1),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) => touchedSpots.map((s) {
              return LineTooltipItem(
                '${s.y.toInt()} repas',
                TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// =========================================================================
// Donut Chart — Meal Distribution
// =========================================================================

class _DonutChart extends StatelessWidget {
  final List<MealDistributionItem> items;
  const _DonutChart({required this.items});

  static final _colors = AppColors.chartColors;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return _emptyText(context);
    final total = items.fold(0, (sum, e) => sum + e.count);
    if (total == 0) return _emptyText(context);

    return Row(
      children: [
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: items.asMap().entries.map((e) {
                final pct = (e.value.count / total * 100).toStringAsFixed(1);
                return PieChartSectionData(
                  value: e.value.count.toDouble(),
                  color: _colors[e.key % _colors.length],
                  radius: 50,
                  title: '$pct%',
                  titleStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: Spacing.md),
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.asMap().entries.map((e) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _colors[e.key % _colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '${e.value.name} (${e.value.count})',
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// =========================================================================
// Horizontal Bar — User Type Distribution
// =========================================================================

class _UserTypeChart extends StatelessWidget {
  final List<UserTypeDistributionItem> items;
  const _UserTypeChart({required this.items});

  static final _colors = AppColors.chartColors.take(3).toList();

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return _emptyText(context);
    final maxCount = items
        .map((e) => e.count)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: items.asMap().entries.map((e) {
        final ratio = maxCount > 0 ? e.value.count / maxCount : 0.0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.value.type,
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                  Text('${e.value.count}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _colors[e.key % _colors.length])),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: ratio,
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
                  color: _colors[e.key % _colors.length],
                  minHeight: 10,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// =========================================================================
// Registration Method (simple bar)
// =========================================================================

class _RegistrationMethodChart extends StatelessWidget {
  final List<RegistrationMethodItem> items;
  const _RegistrationMethodChart({required this.items});

  static final _colors = [AppColors.info, AppColors.success];

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return _emptyText(context);
    final maxCount =
        items.map((e) => e.count).reduce((a, b) => a > b ? a : b).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: items.asMap().entries.map((e) {
        final ratio = maxCount > 0 ? e.value.count / maxCount : 0.0;
        final label = e.value.method == 'FACE' ? 'Reconnaissance faciale' : 'QR Code';
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                  Text('${e.value.count}',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _colors[e.key % _colors.length])),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: ratio,
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
                  color: _colors[e.key % _colors.length],
                  minHeight: 10,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// =========================================================================
// Bar Chart — Peak Hours
// =========================================================================

class _PeakHoursChart extends StatelessWidget {
  final List<PeakHourItem> items;
  const _PeakHoursChart({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return _emptyText(context);
    final sorted = List<PeakHourItem>.from(items)
      ..sort((a, b) => a.hour.compareTo(b.hour));
    final maxCount = sorted
        .map((e) => e.count)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (maxCount * 1.3).toDouble(),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) =>
                BarTooltipItem(
              '${rod.toY.toInt()} repas',
              TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final i = value.toInt();
                if (i < 0 || i >= sorted.length) return const SizedBox();
                return Text(
                  '${sorted[i].hour}h',
                  style: const TextStyle(fontSize: 10),
                );
              },
              reservedSize: 28,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, _) =>
                  Text('${value.toInt()}', style: const TextStyle(fontSize: 10)),
            ),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: sorted.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.count.toDouble(),
                color: Theme.of(context).colorScheme.primary,
                width: 20,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// =========================================================================
// Recent Activity
// =========================================================================

class _RecentActivity extends StatelessWidget {
  final List<RecentRegistrationItem> items;
  const _RecentActivity({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text('Aucune activité récente',
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      );
    }

    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => Divider(height: 1, color: Theme.of(context).dividerColor.withValues(alpha: 0.3)),
      itemBuilder: (context, index) {
        final item = items[index];
        final theme = Theme.of(context);
        final isFace = item.typeIdentification == 'FACE';
        final methodColor = isFace ? AppColors.success : AppColors.info;
        return ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: Spacing.xs,
            vertical: Spacing.xxs,
          ),
          leading: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: methodColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(Spacing.radiusSm),
            ),
            child: Icon(
              isFace ? Icons.face_rounded : Icons.qr_code_rounded,
              size: Spacing.iconSm,
              color: methodColor,
            ),
          ),
          title: Text(
            item.displayName.isNotEmpty ? item.displayName : item.utilisateurUuid,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            '${item.categorieNom ?? "Repas"} • ${item.heureRepas.length >= 19 ? item.heureRepas.substring(11, 19) : item.heureRepas}',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.xs + 2,
              vertical: Spacing.xxs + 1,
            ),
            decoration: BoxDecoration(
              color: methodColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(Spacing.radiusSm),
              border: Border.all(color: methodColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              isFace ? 'Visage' : 'QR',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: methodColor,
              ),
            ),
          ),
        );
      },
    );
  }
}

// =========================================================================
// Quick Actions
// =========================================================================

class _QuickActions extends StatelessWidget {
  final void Function(int index) onSectionTap;

  const _QuickActions({required this.onSectionTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final actions = [
      _ActionItem(icon: Icons.people_rounded, label: 'Employés', index: 0),
      _ActionItem(icon: Icons.school_rounded, label: 'Stagiaires', index: 1),
      _ActionItem(icon: Icons.group_rounded, label: 'Visiteurs', index: 2),
      _ActionItem(icon: Icons.qr_code_rounded, label: 'QR Codes', index: 3),
      _ActionItem(icon: Icons.restaurant_menu_rounded, label: 'Repas', index: 5),
    ];

    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 2,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      physics: const NeverScrollableScrollPhysics(),
      children: actions.map((a) {
        return InkWell(
          onTap: () => onSectionTap(a.index),
          borderRadius: BorderRadius.circular(Spacing.radiusMd),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(Spacing.radiusMd),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(a.icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: Spacing.sm),
                Text(a.label,
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final int index;
  const _ActionItem({
    required this.icon,
    required this.label,
    required this.index,
  });
}

// =========================================================================
// Empty state helper
// =========================================================================

Widget _emptyText(BuildContext context) => Center(
      child: Text('Aucune donnée disponible',
          style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant)),
    );
