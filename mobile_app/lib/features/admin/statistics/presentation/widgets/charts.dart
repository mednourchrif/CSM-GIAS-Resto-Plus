import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/spacing.dart';
import '../../domain/entities/dashboard_stats.dart';

Widget emptyChart(BuildContext context) => Center(
      child: Text('Aucune donnée disponible',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant)),
    );

class MealsPerDayChart extends StatelessWidget {
  final List<MealCountByDate> items;
  const MealsPerDayChart({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return emptyChart(context);
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
                    Text('${v.toInt()}', style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10))),
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
                  child: Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 9)),
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
                Theme.of(context).textTheme.labelSmall!.copyWith(
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

class DonutChart extends StatelessWidget {
  final List<MealDistributionItem> items;
  const DonutChart({required this.items});

  static final _colors = AppColors.chartColors;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return emptyChart(context);
    final total = items.fold(0, (sum, e) => sum + e.count);
    if (total == 0) return emptyChart(context);

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
                  titleStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
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
                padding: const EdgeInsets.symmetric(vertical: Spacing.xxs),
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
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 12),
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

class UserTypeChart extends StatelessWidget {
  final List<UserTypeDistributionItem> items;
  const UserTypeChart({required this.items});

  static final _colors = AppColors.chartColors.take(3).toList();

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return emptyChart(context);
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
          padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(e.value.type,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500, fontSize: 13)),
                  Text('${e.value.count}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _colors[e.key % _colors.length])),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(Spacing.radiusXs),
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

class RegistrationMethodChart extends StatelessWidget {
  final List<RegistrationMethodItem> items;
  const RegistrationMethodChart({required this.items});

  static final _colors = [AppColors.info, AppColors.success];

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return emptyChart(context);
    final maxCount =
        items.map((e) => e.count).reduce((a, b) => a > b ? a : b).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: items.asMap().entries.map((e) {
        final ratio = maxCount > 0 ? e.value.count / maxCount : 0.0;
        final label = e.value.method == 'FACE' ? 'Reconnaissance faciale' : 'QR Code';
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500, fontSize: 13)),
                  Text('${e.value.count}',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _colors[e.key % _colors.length])),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(Spacing.radiusXs),
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

class PeakHoursChart extends StatelessWidget {
  final List<PeakHourItem> items;
  const PeakHoursChart({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return emptyChart(context);
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
              Theme.of(context).textTheme.labelSmall!.copyWith(
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
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10),
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
                  Text('${value.toInt()}', style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 10)),
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
                    top: Radius.circular(Spacing.radiusXs)),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
