import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import '../../../../../core/theme/colors.dart';
import '../../../../../core/theme/spacing.dart';
import '../../../../../shared/widgets/app_dialog.dart';
import '../../domain/entities/meal_history.dart';
import '../providers/meal_history_provider.dart';
import '../providers/meal_history_state.dart';
import '../widgets/meal_history_filters.dart';
import '../widgets/meal_history_stats.dart';
import '../widgets/meal_status_badge.dart';

class MealHistoryListScreen extends ConsumerStatefulWidget {
  const MealHistoryListScreen({super.key});

  @override
  ConsumerState<MealHistoryListScreen> createState() =>
      _MealHistoryListScreenState();
}

class _MealHistoryListScreenState
    extends ConsumerState<MealHistoryListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() {
      ref.read(mealHistoryProvider.notifier).loadMeals(refresh: true);
      ref.read(mealHistoryProvider.notifier).loadStats();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(mealHistoryProvider.notifier).setSearch(
            query.isEmpty ? null : query,
          );
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(mealHistoryProvider.notifier).nextPage();
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(mealHistoryProvider.notifier).loadMeals(refresh: true);
    await ref.read(mealHistoryProvider.notifier).loadStats();
  }

  void _showFilters(MealHistoryState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => MealHistoryFilters(
        currentDateFrom: state.dateFrom,
        currentDateTo: state.dateTo,
        currentCategorieUuid: state.categorieUuid,
        currentTypeIdentification: state.typeIdentification,
        currentUserType: state.userType,
        onDateChanged: ({String? dateFrom, String? dateTo}) {
          ref.read(mealHistoryProvider.notifier).setDateFilter(
                dateFrom: dateFrom,
                dateTo: dateTo,
              );
        },
        onCategorieChanged: (v) =>
            ref.read(mealHistoryProvider.notifier).setCategorieFilter(v),
        onTypeIdentificationChanged: (v) =>
            ref.read(mealHistoryProvider.notifier)
                .setTypeIdentificationFilter(v),
        onUserTypeChanged: (v) =>
            ref.read(mealHistoryProvider.notifier).setUserTypeFilter(v),
        onReset: () =>
            ref.read(mealHistoryProvider.notifier).resetFilters(),
      ),
    );
  }

  void _exportCsv(MealHistoryState state) {
    final buffer = StringBuffer();
    buffer.writeln('UUID;Utilisateur;Email;Type ID;Catégorie;Date;Heure');
    for (final meal in state.meals) {
      buffer.writeln(
        '${meal.uuid};${meal.displayName};${meal.email ?? ""};'
        '${meal.typeIdentification.name};${meal.categorieNom ?? ""};'
        '${meal.dateRepas.toIso8601String().split('T').first};'
        '${meal.heureRepas}',
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Export CSV : ${state.meals.length} lignes générées'),
        action: SnackBarAction(
          label: 'Copier',
          onPressed: () =>
              _copyToClipboard(buffer.toString()),
        ),
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Données copiées dans le presse-papier')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mealHistoryProvider);
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des repas'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: state.hasActiveFilters,
              child: const Icon(Icons.filter_list_rounded),
            ),
            onPressed: () => _showFilters(state),
            tooltip: 'Filtres',
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            onPressed: state.meals.isEmpty ? null : () => _exportCsv(state),
            tooltip: 'Exporter CSV',
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _onRefresh,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: Column(
        children: [
          if (state.hasActiveFilters)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.sm,
              ),
              color: theme.colorScheme.primaryContainer,
              child: Row(
                children: [
                  Icon(Icons.filter_alt,
                      size: 16,
                      color: theme.colorScheme.onPrimaryContainer),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(
                      'Filtres actifs',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () =>
                        ref.read(mealHistoryProvider.notifier).resetFilters(),
                    icon: const Icon(Icons.clear_all, size: 16),
                    label: const Text('Effacer'),
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(Spacing.md, Spacing.sm, Spacing.md, 0),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Rechercher par nom, email ou UUID...',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Spacing.radiusMd),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.md,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: Spacing.xs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: MealHistoryStats(
              stats: state.stats,
              isLoading: state.isLoadingStats,
            ),
          ),
          const SizedBox(height: Spacing.xs),
          if (state.totalCount > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
              child: Row(
                children: [
                  Text(
                    '${state.totalCount} repas',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  if (state.currentPage > 1 || state.hasNextPage)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          onPressed: state.hasPreviousPage
                              ? () => ref.read(mealHistoryProvider.notifier)
                                  .previousPage()
                              : null,
                          visualDensity: VisualDensity.compact,
                          tooltip: 'Page précédente',
                        ),
                        Text(
                          '${state.currentPage}/${state.totalPages}',
                          style: theme.textTheme.bodySmall,
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          onPressed: state.hasNextPage
                              ? () => ref.read(mealHistoryProvider.notifier)
                                  .nextPage()
                              : null,
                          visualDensity: VisualDensity.compact,
                          tooltip: 'Page suivante',
                        ),
                      ],
                    ),
                ],
              ),
            ),
          const SizedBox(height: Spacing.xs),
          Expanded(
            child: _buildBody(state, theme, isDesktop),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(MealHistoryState state, ThemeData theme, bool isDesktop) {
    if (state.isLoading && state.meals.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.meals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: Spacing.md),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: Spacing.xl),
              FilledButton(
                onPressed: _onRefresh,
                child: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.meals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.restaurant_outlined,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: Spacing.md),
              Text(
                state.search != null
                    ? 'Aucun repas trouvé pour "${state.search}"'
                    : 'Aucun repas enregistré',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (isDesktop) {
      return _buildDataTable(state, theme);
    }

    return _buildCardList(state, theme);
  }

  Widget _buildCardList(MealHistoryState state, ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
        itemCount: state.meals.length,
        itemBuilder: (context, index) {
          final meal = state.meals[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: Spacing.sm),
            child: _MealCard(meal: meal, theme: theme),
          );
        },
      ),
    );
  }

  Widget _buildDataTable(MealHistoryState state, ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(Spacing.md),
        children: [
          DataTable(
            sortColumnIndex: 0,
            sortAscending: state.order == 'asc',
            headingRowHeight: 48,
            dataRowMinHeight: 48,
            dataRowMaxHeight: 64,
            columns: [
              DataColumn(
                label: const Text('Date'),
                onSort: (_, _) =>
                    ref.read(mealHistoryProvider.notifier).setSort('date_repas'),
              ),
              const DataColumn(label: Text('Utilisateur')),
              const DataColumn(label: Text('Email')),
              DataColumn(
                label: const Text('Type ID'),
                numeric: false,
              ),
              const DataColumn(label: Text('Catégorie')),
              const DataColumn(label: Text('Heure')),
            ],
            rows: state.meals.map((m) {
              return DataRow(
                onSelectChanged: (_) => _showDetail(m),
                cells: [
                  DataCell(Text(
                    '${m.dateRepas.day.toString().padLeft(2, '0')}/'
                    '${m.dateRepas.month.toString().padLeft(2, '0')}/'
                    '${m.dateRepas.year}',
                  )),
                  DataCell(Text(m.displayName)),
                  DataCell(Text(m.email ?? '-')),
                  DataCell(MealStatusBadge(type: m.typeIdentification)),
                  DataCell(Text(m.categorieNom ?? '-')),
                  DataCell(Text(m.heureRepas)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _showDetail(MealHistory meal) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _MealDetailScreen(meal: meal),
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final MealHistory meal;
  final ThemeData theme;

  const _MealCard({required this.meal, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Spacing.radiusMd),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.xs),
        leading: CircleAvatar(
          backgroundColor: meal.isFace
              ? AppColors.success.withValues(alpha: 0.15)
              : AppColors.info.withValues(alpha: 0.15),
          child: Icon(
            meal.isFace ? Icons.face : Icons.qr_code,
            color: meal.isFace ? AppColors.success : AppColors.info,
          ),
        ),
        title: Text(
          meal.displayName.isNotEmpty ? meal.displayName : meal.utilisateurUuid,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Row(
          children: [
            Text(
              '${meal.dateRepas.day.toString().padLeft(2, '0')}/'
              '${meal.dateRepas.month.toString().padLeft(2, '0')}/'
              '${meal.dateRepas.year}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(width: Spacing.sm),
            Text(
              meal.heureRepas,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: Spacing.sm),
            if (meal.categorieNom != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(Spacing.radiusSm),
                ),
                child: Text(
                  meal.categorieNom!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
          ],
        ),
        trailing: MealStatusBadge(type: meal.typeIdentification),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => _MealDetailScreen(meal: meal),
            ),
          );
        },
      ),
    );
  }
}

class _MealDetailScreen extends StatelessWidget {
  final MealHistory meal;

  const _MealDetailScreen({required this.meal});

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
                  _DetailRow(
                    label: 'UUID',
                    value: meal.uuid,
                    theme: theme,
                  ),
                  const Divider(),
                  _DetailRow(
                    label: 'Utilisateur',
                    value: meal.displayName.isNotEmpty
                        ? meal.displayName
                        : 'N/A',
                    theme: theme,
                  ),
                  const Divider(),
                  _DetailRow(
                    label: 'Email',
                    value: meal.email ?? 'N/A',
                    theme: theme,
                  ),
                  const Divider(),
                  _DetailRow(
                    label: 'UUID Utilisateur',
                    value: meal.utilisateurUuid,
                    theme: theme,
                  ),
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
                  _DetailRow(
                    label: 'Heure',
                    value: meal.heureRepas,
                    theme: theme,
                  ),
                  const Divider(),
                  _DetailRow(
                    label: 'Catégorie',
                    value: meal.categorieNom ?? 'N/A',
                    theme: theme,
                  ),
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
