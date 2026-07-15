import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/spacing.dart';
import '../../../../../shared/widgets/error_state.dart';
import '../../../../../shared/widgets/shimmer_loading.dart';
import '../../domain/entities/dashboard_stats.dart';
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
                    height: 280,
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
                    height: 280,
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
              height: 260,
              child: MealsPerDayChart(items: stats.mealsPerDay),
            ),
          ),
          _SectionCard(
            title: 'Distribution des repas',
            child: SizedBox(
              height: 260,
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
                    height: 240,
                    child: UserTypeChart(items: stats.userTypeDistribution),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: _SectionCard(
                  title: 'Méthode d\'inscription',
                  child: SizedBox(
                    height: 240,
                    child: RegistrationMethodChart(items: stats.registrationMethods),
                  ),
                ),
              ),
              Expanded(
                child: _SectionCard(
                  title: 'Heures d\'affluence',
                  child: SizedBox(
                    height: 240,
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
              height: 240,
              child: UserTypeChart(items: stats.userTypeDistribution),
            ),
          ),
          _SectionCard(
            title: 'Méthode d\'inscription',
            child: SizedBox(
              height: 240,
              child: RegistrationMethodChart(items: stats.registrationMethods),
            ),
          ),
          _SectionCard(
            title: 'Heures d\'affluence',
            child: SizedBox(
              height: 240,
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
                    height: 400,
                    child: RecentActivityWidget(items: stats.recentRegistrations),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                flex: 2,
                child: _SectionCard(
                  title: 'Accès rapides',
                  child: SizedBox(
                    height: 240,
                    child: QuickActions(onSectionTap: widget.onSectionTap ?? _navigateTo),
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          _SectionCard(
            title: 'Activité récente',
            child: SizedBox(
              height: 360,
              child: RecentActivityWidget(items: stats.recentRegistrations),
            ),
          ),
          _SectionCard(
            title: 'Accès rapides',
            child: SizedBox(
              height: 240,
              child: QuickActions(onSectionTap: widget.onSectionTap ?? _navigateTo),
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
