import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/spacing.dart';
import '../../../../../shared/widgets/error_state.dart';
import '../../../../../shared/widgets/shimmer_loading.dart';
import '../providers/statistics_provider.dart';
import '../providers/statistics_state.dart';
import '../widgets/charts.dart';
import '../widgets/overview_cards.dart';
import '../widgets/quick_actions.dart';
import '../widgets/recent_activity.dart';

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
    Future.microtask(() => ref.read(statisticsProvider.notifier).load());
  }

  Future<void> _onRefresh() async {
    await ref.read(statisticsProvider.notifier).load();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(statisticsProvider);
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    final isDesktop = media.size.width >= 900;
    final isLandscapeTablet = isDesktop && media.size.width > media.size.height;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: _buildBody(state, theme, isDesktop, isLandscapeTablet),
    );
  }

  Widget _buildBody(
    StatisticsState state,
    ThemeData theme,
    bool isDesktop,
    bool isLandscapeTablet,
  ) {
    final pagePadding = EdgeInsets.all(
      isLandscapeTablet ? Spacing.lg : Spacing.md,
    );

    if (state.isLoading && state.stats == null) {
      return SingleChildScrollView(
        padding: pagePadding,
        child: Column(
          children: [
            if (isDesktop)
              const _IntroBanner(
                title: 'Tableau de bord',
                subtitle:
                    'Vue d’ensemble des repas, de l’activité récente et des accès rapides.',
              ),
            const ShimmerStatGrid(count: 10),
            const SizedBox(height: Spacing.md),
            ShimmerCard(
              height: isLandscapeTablet
                  ? 260
                  : isDesktop
                  ? 320
                  : 280,
            ),
            ShimmerCard(height: isLandscapeTablet ? 220 : 280),
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
      padding: pagePadding,
      children: [
        if (isDesktop)
          const _IntroBanner(
            title: 'Tableau de bord',
            subtitle:
                'Vue d’ensemble des repas, de l’activité récente et des accès rapides.',
          ),
        OverviewCards(stats: stats),
        const SizedBox(height: Spacing.md),
        if (isDesktop) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: _SectionCard(
                  title: 'Repas par jour (cette semaine)',
                  child: SizedBox(
                    height: isLandscapeTablet ? 240 : 280,
                    child: MealsPerDayChart(items: stats.mealsPerDay),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                flex: 2,
                child: _SectionCard(
                  title: 'Distribution des repas',
                  child: SizedBox(
                    height: isLandscapeTablet ? 240 : 280,
                    child: DonutChart(items: stats.mealDistribution),
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          _SectionCard(
            title: 'Repas par jour (cette semaine)',
            child: SizedBox(
              height: isLandscapeTablet ? 220 : 260,
              child: MealsPerDayChart(items: stats.mealsPerDay),
            ),
          ),
          _SectionCard(
            title: 'Distribution des repas',
            child: SizedBox(
              height: isLandscapeTablet ? 220 : 260,
              child: DonutChart(items: stats.mealDistribution),
            ),
          ),
        ],
        const SizedBox(height: Spacing.md),
        if (isDesktop) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _SectionCard(
                  title: 'Type d\'utilisateur',
                  child: SizedBox(
                    height: isLandscapeTablet ? 220 : 240,
                    child: UserTypeChart(items: stats.userTypeDistribution),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: _SectionCard(
                  title: 'Méthode d\'inscription',
                  child: SizedBox(
                    height: isLandscapeTablet ? 220 : 240,
                    child: RegistrationMethodChart(
                      items: stats.registrationMethods,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: _SectionCard(
                  title: 'Heures d\'affluence',
                  child: SizedBox(
                    height: isLandscapeTablet ? 220 : 240,
                    child: PeakHoursChart(items: stats.peakHours),
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          _SectionCard(
            title: 'Type d\'utilisateur',
            child: SizedBox(
              height: isLandscapeTablet ? 220 : 240,
              child: UserTypeChart(items: stats.userTypeDistribution),
            ),
          ),
          _SectionCard(
            title: 'Méthode d\'inscription',
            child: SizedBox(
              height: isLandscapeTablet ? 220 : 240,
              child: RegistrationMethodChart(items: stats.registrationMethods),
            ),
          ),
          _SectionCard(
            title: 'Heures d\'affluence',
            child: SizedBox(
              height: isLandscapeTablet ? 220 : 240,
              child: PeakHoursChart(items: stats.peakHours),
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
                child: _SectionCard(
                  title: 'Activité récente',
                  child: SizedBox(
                    height: isLandscapeTablet ? 300 : 400,
                    child: RecentActivityWidget(
                      items: stats.recentRegistrations,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                flex: 2,
                child: _SectionCard(
                  title: 'Accès rapides',
                  child: SizedBox(
                    height: isLandscapeTablet ? 210 : 240,
                    child: QuickActions(
                      onSectionTap: widget.onSectionTap ?? _navigateTo,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          _SectionCard(
            title: 'Activité récente',
            child: SizedBox(
              height: isLandscapeTablet ? 300 : 360,
              child: RecentActivityWidget(items: stats.recentRegistrations),
            ),
          ),
          _SectionCard(
            title: 'Accès rapides',
            child: SizedBox(
              height: isLandscapeTablet ? 210 : 240,
              child: QuickActions(
                onSectionTap: widget.onSectionTap ?? _navigateTo,
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _navigateTo(int index) {
    Navigator.of(context).maybePop();
  }
}

class _IntroBanner extends StatelessWidget {
  final String title;
  final String subtitle;

  const _IntroBanner({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.md),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Spacing.lg),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primaryContainer.withValues(alpha: 0.65),
              theme.colorScheme.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(Spacing.radiusXl),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(Spacing.radiusMd),
              ),
              child: Icon(
                Icons.dashboard_rounded,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: Spacing.xxs),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

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
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: Spacing.sm),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
