import 'package:flutter/material.dart';
import '../../../core/theme/spacing.dart';

/// Reusable dashboard stat card widget.
///
/// Displays a metric value, label, icon, and optional trend indicator.
class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  final Color? color;
  final double? trend;
  final String? trendLabel;
  final bool compact;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    required this.icon,
    this.color,
    this.trend,
    this.trendLabel,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardColor = color ?? theme.colorScheme.primary;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(compact ? Spacing.sm + 4 : Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon & Trend Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Icon in gradient container
                Container(
                  width: compact ? 36 : 44,
                  height: compact ? 36 : 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        cardColor.withValues(alpha: 0.9),
                        cardColor.withValues(alpha: 0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(Spacing.radiusMd),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: compact ? Spacing.iconSm : Spacing.iconMd,
                  ),
                ),
                // Trend indicator
                if (trend != null) _TrendBadge(trend: trend!),
              ],
            ),
            SizedBox(height: compact ? Spacing.sm : Spacing.md),
            // Value
            Text(
              value,
              style: compact
                  ? theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                      height: 1.0,
                    )
                  : theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                      height: 1.0,
                    ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: Spacing.xxs),
            // Label
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (trendLabel != null) ...[
              const SizedBox(height: Spacing.xxs),
              Text(
                trendLabel!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TrendBadge extends StatelessWidget {
  final double trend;

  const _TrendBadge({required this.trend});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = trend >= 0;
    final color = isPositive ? const Color(0xFF1B8A1B) : theme.colorScheme.error;
    final icon = isPositive ? Icons.trending_up_rounded : Icons.trending_down_rounded;
    final sign = isPositive ? '+' : '';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.xs + 2,
        vertical: Spacing.xxs + 1,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(Spacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 2),
          Text(
            '$sign${trend.toStringAsFixed(1)}%',
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
