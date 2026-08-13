import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/spacing.dart';
import '../../../../providers.dart';
import '../../data/receipt_print_service.dart';
import '../../domain/entities/receipt.dart';
import '../providers/receipt_provider.dart';

class ReceiptListScreen extends ConsumerStatefulWidget {
  const ReceiptListScreen({super.key});

  @override
  ConsumerState<ReceiptListScreen> createState() => _ReceiptListScreenState();
}

class _ReceiptListScreenState extends ConsumerState<ReceiptListScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(receiptProvider.notifier).load(page: 1));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _search(String value) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => ref.read(receiptProvider.notifier).setSearch(value.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(receiptProvider);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reçus de repas'),
        actions: [
          IconButton(
            onPressed: () => ref.read(receiptProvider.notifier).load(),
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(receiptProvider.notifier).load(),
          child: ListView(
            padding: const EdgeInsets.all(Spacing.md),
            children: [
              _ReceiptHero(total: state.total),
              const SizedBox(height: Spacing.md),
              TextField(
                controller: _searchController,
                onChanged: _search,
                decoration: InputDecoration(
                  hintText: 'Numéro, nom ou matricule...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            _search('');
                            setState(() {});
                          },
                          icon: const Icon(Icons.clear_rounded),
                        ),
                ),
              ),
              const SizedBox(height: Spacing.sm),
              _FilterBar(state: state),
              const SizedBox(height: Spacing.md),
              if (state.isLoading && state.receipts.isEmpty)
                const SizedBox(
                  height: 260,
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (state.error != null && state.receipts.isEmpty)
                _MessageCard(
                  icon: Icons.error_outline_rounded,
                  message: state.error!,
                )
              else if (state.receipts.isEmpty)
                const _MessageCard(
                  icon: Icons.receipt_long_outlined,
                  message: 'Aucun reçu ne correspond aux filtres.',
                )
              else
                ...state.receipts.map(
                  (receipt) => _ReceiptCard(receipt: receipt),
                ),
              if (state.totalPages > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: state.page > 1
                          ? () => ref
                                .read(receiptProvider.notifier)
                                .load(page: state.page - 1)
                          : null,
                      icon: const Icon(Icons.chevron_left_rounded),
                    ),
                    Text(
                      '${state.page} / ${state.totalPages}',
                      style: theme.textTheme.labelLarge,
                    ),
                    IconButton(
                      onPressed: state.page < state.totalPages
                          ? () => ref
                                .read(receiptProvider.notifier)
                                .load(page: state.page + 1)
                          : null,
                      icon: const Icon(Icons.chevron_right_rounded),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceiptHero extends StatelessWidget {
  final int total;
  const _ReceiptHero({required this.total});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(Spacing.lg),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Theme.of(context).colorScheme.primary,
          const Color(0xFF0A6A8B),
        ],
      ),
      borderRadius: BorderRadius.circular(Spacing.radiusXl),
    ),
    child: Row(
      children: [
        const Icon(Icons.receipt_long_rounded, size: 42, color: Colors.white),
        const SizedBox(width: Spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Journal des reçus',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '$total reçu(s) enregistré(s)',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _FilterBar extends ConsumerWidget {
  final ReceiptState state;
  const _FilterBar({required this.state});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Wrap(
    spacing: Spacing.sm,
    runSpacing: Spacing.sm,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      DropdownButton<String>(
        value: state.category,
        hint: const Text('Type plat'),
        items: const ['Plat', 'Pizza', 'Sandwich']
            .map((value) => DropdownMenuItem(value: value, child: Text(value)))
            .toList(),
        onChanged: (value) => ref
            .read(receiptProvider.notifier)
            .setFilters(
              dateFrom: state.dateFrom,
              dateTo: state.dateTo,
              category: value,
              userType: state.userType,
              identificationType: state.identificationType,
            ),
      ),
      DropdownButton<String>(
        value: state.userType,
        hint: const Text('Profil'),
        items: const ['EMPLOYE', 'STAGIAIRE', 'VISITEUR']
            .map((value) => DropdownMenuItem(value: value, child: Text(value)))
            .toList(),
        onChanged: (value) => ref
            .read(receiptProvider.notifier)
            .setFilters(
              dateFrom: state.dateFrom,
              dateTo: state.dateTo,
              category: state.category,
              userType: value,
              identificationType: state.identificationType,
            ),
      ),
      DropdownButton<String>(
        value: state.identificationType,
        hint: const Text('Identification'),
        items: const ['QR', 'FACE']
            .map((value) => DropdownMenuItem(value: value, child: Text(value)))
            .toList(),
        onChanged: (value) => ref
            .read(receiptProvider.notifier)
            .setFilters(
              dateFrom: state.dateFrom,
              dateTo: state.dateTo,
              category: state.category,
              userType: state.userType,
              identificationType: value,
            ),
      ),
      OutlinedButton.icon(
        onPressed: () async {
          final range = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2024),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            initialDateRange: state.dateFrom == null || state.dateTo == null
                ? null
                : DateTimeRange(start: state.dateFrom!, end: state.dateTo!),
          );
          if (range == null) return;
          await ref
              .read(receiptProvider.notifier)
              .setFilters(
                dateFrom: range.start,
                dateTo: range.end,
                category: state.category,
                userType: state.userType,
                identificationType: state.identificationType,
              );
        },
        icon: const Icon(Icons.date_range_rounded),
        label: Text(state.dateFrom == null ? 'Période' : 'Période active'),
      ),
      TextButton.icon(
        onPressed: () => ref.read(receiptProvider.notifier).resetFilters(),
        icon: const Icon(Icons.filter_alt_off_rounded),
        label: const Text('Réinitialiser'),
      ),
    ],
  );
}

class _ReceiptCard extends ConsumerWidget {
  final Receipt receipt;
  const _ReceiptCard({required this.receipt});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final date = DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(receipt.servedAt.toLocal());
    return Card(
      margin: const EdgeInsets.only(bottom: Spacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: const Icon(Icons.receipt_rounded),
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    receipt.fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text('${receipt.number} • ${receipt.categoryName} • $date'),
                  Text(
                    '${receipt.userType}${receipt.employeeNumber == null ? '' : ' • ${receipt.employeeNumber}'} • ${receipt.identificationType}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            IconButton.filledTonal(
              onPressed: () => ReceiptPrintService(
                ref.read(apiClientProvider).dio,
              ).printReceipt(receipt),
              icon: const Icon(Icons.print_rounded),
              tooltip: 'Imprimer',
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final IconData icon;
  final String message;
  const _MessageCard({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 240,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 56,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: Spacing.sm),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
