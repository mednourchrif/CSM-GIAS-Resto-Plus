import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/spacing.dart';
import '../../../../../shared/widgets/empty_state.dart';
import '../../../../../shared/widgets/error_state.dart';
import '../../../../../shared/widgets/shimmer_loading.dart';
import '../../../../../shared/widgets/status_badge.dart';
import '../../domain/entities/visitor.dart';
import '../providers/visitor_provider.dart';
import '../providers/visitor_state.dart';
import '../widgets/visitor_card.dart';
import 'visitor_detail_screen.dart';
import 'visitor_form_screen.dart';

class VisitorListScreen extends ConsumerStatefulWidget {
  const VisitorListScreen({super.key});

  @override
  ConsumerState<VisitorListScreen> createState() => _VisitorListScreenState();
}

class _VisitorListScreenState extends ConsumerState<VisitorListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() => ref.read(visitorProvider.notifier).refresh());
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
      ref.read(visitorProvider.notifier).search(query);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(visitorProvider.notifier).loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(visitorProvider.notifier).refresh();
  }

  void _showDetail(Visitor visitor) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VisitorDetailScreen(visitor: visitor),
      ),
    );
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (_) => const VisitorFormScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(visitorProvider);
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visiteurs'),
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
                hintText: 'Rechercher par nom, prénom, email ou organisation...',
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

  Widget _buildBody(VisitorState state, ThemeData theme, bool isDesktop) {
    if (state.isLoading && state.visitors.isEmpty) {
      return isDesktop ? const ShimmerDataTable() : const ShimmerList();
    }

    if (state.error != null && state.visitors.isEmpty) {
      return ErrorState(message: state.error!, onRetry: _onRefresh);
    }

    if (state.visitors.isEmpty) {
      return EmptyState(
        icon: Icons.group_outlined,
        title: state.searchQuery.isNotEmpty
            ? 'Aucun résultat pour "${state.searchQuery}"'
            : 'Aucun visiteur',
        subtitle: state.searchQuery.isEmpty
            ? 'Ajoutez un visiteur pour commencer.'
            : null,
        actionLabel: state.searchQuery.isEmpty ? 'Ajouter' : null,
        onAction: state.searchQuery.isEmpty ? _showCreateDialog : null,
      );
    }

    if (isDesktop) return _buildDataTable(state, theme);
    return _buildCardList(state);
  }

  Widget _buildCardList(VisitorState state) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
        itemCount: state.visitors.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.visitors.length) {
            return const Padding(
              padding: EdgeInsets.all(Spacing.md),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final visitor = state.visitors[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: Spacing.sm),
            child: VisitorCard(
              visitor: visitor,
              onTap: () => _showDetail(visitor),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDataTable(VisitorState state, ThemeData theme) {
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
              DataColumn(label: Text('Organisation')),
              DataColumn(label: Text('Date de visite')),
              DataColumn(label: Text('Statut')),
            ],
            rows: state.visitors.map((v) {
              return DataRow(
                onSelectChanged: (_) => _showDetail(v),
                cells: [
                  DataCell(Text(v.nom)),
                  DataCell(Text(v.prenom)),
                  DataCell(Text(v.societe ?? '-')),
                  DataCell(Text(v.formattedDate)),
                  DataCell(StatusBadge(status: v.statut)),
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
