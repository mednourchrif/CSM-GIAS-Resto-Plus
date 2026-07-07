import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/spacing.dart';
import '../../../../../shared/widgets/empty_state.dart';
import '../../../../../shared/widgets/error_state.dart';
import '../../../../../shared/widgets/shimmer_loading.dart';
import '../../../../../shared/widgets/status_badge.dart';
import '../../domain/entities/intern.dart';
import '../providers/intern_provider.dart';
import '../providers/intern_state.dart';
import '../widgets/intern_card.dart';
import 'intern_detail_screen.dart';
import 'intern_form_screen.dart';

class InternListScreen extends ConsumerStatefulWidget {
  const InternListScreen({super.key});

  @override
  ConsumerState<InternListScreen> createState() => _InternListScreenState();
}

class _InternListScreenState extends ConsumerState<InternListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() => ref.read(internProvider.notifier).refresh());
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
      ref.read(internProvider.notifier).search(query);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(internProvider.notifier).loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(internProvider.notifier).refresh();
  }

  void _showDetail(Intern intern) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => InternDetailScreen(intern: intern),
      ),
    );
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (_) => const InternFormScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(internProvider);
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stagiaires'),
        actions: [
          if (isDesktop)
            FilledButton.icon(
              onPressed: _showCreateDialog,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Ajouter'),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.md,
              Spacing.sm,
              Spacing.md,
              0,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Rechercher par nom, prénom ou matricule...',
                prefixIcon: const Icon(Icons.search_rounded),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Spacing.radiusMd),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: Spacing.md,
                  vertical: Spacing.sm,
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
          const SizedBox(height: Spacing.sm),
          Expanded(
            child: _buildBody(state, theme, isDesktop),
          ),
        ],
      ),
      floatingActionButton: isDesktop
          ? null
          : FloatingActionButton(
              onPressed: _showCreateDialog,
              child: const Icon(Icons.add_rounded),
            ),
    );
  }

  Widget _buildBody(InternState state, ThemeData theme, bool isDesktop) {
    if (state.isLoading && state.interns.isEmpty) {
      return isDesktop ? const ShimmerDataTable() : const ShimmerList();
    }

    if (state.error != null && state.interns.isEmpty) {
      return ErrorState(message: state.error!, onRetry: _onRefresh);
    }

    if (state.interns.isEmpty) {
      return EmptyState(
        icon: Icons.school_rounded,
        title: state.searchQuery.isNotEmpty
            ? 'Aucun résultat pour "${state.searchQuery}"'
            : 'Aucun stagiaire',
        subtitle: state.searchQuery.isEmpty
            ? 'Ajoutez un stagiaire pour commencer.'
            : null,
        actionLabel: state.searchQuery.isEmpty ? 'Ajouter' : null,
        onAction: state.searchQuery.isEmpty ? _showCreateDialog : null,
      );
    }

    if (isDesktop) return _buildDataTable(state, theme);
    return _buildCardList(state);
  }

  Widget _buildCardList(InternState state) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
        itemCount: state.interns.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.interns.length) {
            return const Padding(
              padding: EdgeInsets.all(Spacing.md),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final intern = state.interns[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: Spacing.sm),
            child: InternCard(
              intern: intern,
              onTap: () => _showDetail(intern),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDataTable(InternState state, ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(Spacing.md),
        children: [
          DataTable(
            sortColumnIndex: 0,
            headingRowHeight: 48,
            dataRowMinHeight: 48,
            dataRowMaxHeight: 64,
            columns: const [
              DataColumn(label: Text('Nom')),
              DataColumn(label: Text('Prénom')),
              DataColumn(label: Text('Matricule')),
              DataColumn(label: Text('Période de stage')),
              DataColumn(label: Text('Statut')),
            ],
            rows: state.interns.map((i) {
              return DataRow(
                onSelectChanged: (_) => _showDetail(i),
                cells: [
                  DataCell(Text(i.nom)),
                  DataCell(Text(i.prenom)),
                  DataCell(Text(i.matricule)),
                  DataCell(Text(i.periodeStage)),
                  DataCell(StatusBadge(status: i.statut)),
                ],
              );
            }).toList(),
          ),
          if (state.hasMore)
            Padding(
              padding: const EdgeInsets.all(Spacing.md),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
