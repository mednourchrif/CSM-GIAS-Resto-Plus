import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/spacing.dart';
import '../../../../../shared/widgets/empty_state.dart';
import '../../../../../shared/widgets/error_state.dart';
import '../../../../../shared/widgets/shimmer_loading.dart';
import '../../domain/entities/employee.dart';
import '../providers/employee_provider.dart';
import '../providers/employee_state.dart';
import '../widgets/employee_card.dart';
import '../widgets/employee_status_badge.dart';
import 'employee_detail_screen.dart';
import 'employee_form_screen.dart';

class EmployeeListScreen extends ConsumerStatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  ConsumerState<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends ConsumerState<EmployeeListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    Future.microtask(() => ref.read(employeeProvider.notifier).refresh());
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
      ref.read(employeeProvider.notifier).search(query);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(employeeProvider.notifier).loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(employeeProvider.notifier).refresh();
  }

  void _showDetail(Employee employee) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EmployeeDetailScreen(uuid: employee.uuid),
      ),
    );
  }

  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (_) => const EmployeeFormScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(employeeProvider);
    final theme = Theme.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employés'),
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
                hintText: 'Rechercher par nom ou prénom...',
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

  Widget _buildBody(EmployeeState state, ThemeData theme, bool isDesktop) {
    if (state.isLoading && state.employees.isEmpty) {
      return isDesktop
          ? const ShimmerDataTable()
          : const ShimmerList();
    }

    if (state.error != null && state.employees.isEmpty) {
      return ErrorState(
        message: state.error!,
        onRetry: _onRefresh,
      );
    }

    if (state.employees.isEmpty) {
      return EmptyState(
        icon: Icons.people_outline_rounded,
        title: state.searchQuery.isNotEmpty
            ? 'Aucun résultat pour "${state.searchQuery}"'
            : 'Aucun employé',
        subtitle: state.searchQuery.isEmpty
            ? 'Ajoutez un employé pour commencer.'
            : null,
        actionLabel: state.searchQuery.isEmpty ? 'Ajouter' : null,
        onAction: state.searchQuery.isEmpty ? _showCreateDialog : null,
      );
    }

    if (isDesktop) {
      return _buildDataTable(state, theme);
    }

    return _buildCardList(state);
  }

  Widget _buildCardList(EmployeeState state) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
        itemCount: state.employees.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.employees.length) {
            return const Padding(
              padding: EdgeInsets.all(Spacing.md),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final employee = state.employees[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: Spacing.sm),
            child: EmployeeCard(
              employee: employee,
              onTap: () => _showDetail(employee),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDataTable(EmployeeState state, ThemeData theme) {
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
              DataColumn(label: Text('Statut')),
              DataColumn(label: Text('Enrôlement')),
              DataColumn(label: Text('Modifié le')),
            ],
            rows: state.employees.map((e) {
              return DataRow(
                onSelectChanged: (_) => _showDetail(e),
                cells: [
                  DataCell(Text(e.nom)),
                  DataCell(Text(e.prenom)),
                  DataCell(Text(e.matricule)),
                  DataCell(EmployeeStatusBadge(status: e.statut)),
                  DataCell(EmployeeStatusBadge(status: e.statutEnrolement)),
                  DataCell(Text(_formatDate(e.updatedAt))),
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

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/'
        '${dt.month.toString().padLeft(2, '0')}/'
        '${dt.year}';
  }
}
