import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/report_state.dart';
import '../providers/report_provider.dart';
import '../widgets/report_filters.dart';
import '../widgets/report_overview_cards.dart';
import '../widgets/report_charts.dart';
import '../widgets/report_preview.dart';
import '../widgets/report_export.dart';
import '../../domain/entities/report_entity.dart';

class ReportScreen extends ConsumerWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapports'),
        actions: [
          if (state.report != null && !state.isLoading)
            IconButton(
              icon: const Icon(Icons.preview_rounded),
              tooltip: 'Aperçu',
              onPressed: () => ReportPreviewDialog.show(context, state.report!),
            ),
          if (state.report != null && !state.isLoading)
            IconButton(
              icon: const Icon(Icons.file_download_rounded),
              tooltip: 'Exporter',
              onPressed: () => _showExportDialog(context, ref, state.report!),
            ),
        ],
      ),
      body: _buildBody(context, theme, state, ref),
    );
  }

  Widget _buildBody(BuildContext context, ThemeData theme, ReportState state, WidgetRef ref) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 64, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(state.error!, style: theme.textTheme.bodyLarge, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => ref.read(reportProvider.notifier).clearError(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(reportProvider.notifier).generate(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ReportFilters(),
            const SizedBox(height: 24),
            if (state.report != null) ...[
              _buildReportHeader(context, state.report!),
              const SizedBox(height: 20),
              ReportOverviewCards(overview: state.report!.overview),
              const SizedBox(height: 24),
              Text('Graphiques', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              ReportCharts(report: state.report!),
              const SizedBox(height: 24),
              _buildDistributionTable(context, state.report!),
              const SizedBox(height: 24),
              _buildActionButtons(context, ref, state.report!),
            ] else ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 80),
                  child: Column(
                    children: [
                      Icon(Icons.bar_chart_rounded, size: 80, color: theme.colorScheme.primary.withAlpha(100)),
                      const SizedBox(height: 24),
                      Text(
                        'Générer un rapport d\'activité',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sélectionnez les filtres puis cliquez sur Générer',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReportHeader(BuildContext context, Report report) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.description_rounded, color: theme.colorScheme.onPrimaryContainer),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rapport d\'activité',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    report.periodLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              report.dateFrom.isNotEmpty ? report.dateFrom : 'Toutes les dates',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionTable(BuildContext context, Report report) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Répartition', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            DataTable(
              columns: const [
                DataColumn(label: Text('Catégorie')),
                DataColumn(label: Text('Total')),
              ],
              rows: [
                ...report.mealsByCategory.map((item) => DataRow(cells: [
                  DataCell(Text(item.label)),
                  DataCell(Text(item.count.toString())),
                ])),
                ...report.registrationMethods.map((item) => DataRow(cells: [
                  DataCell(Text('Méthode: ${item.label}')),
                  DataCell(Text(item.count.toString())),
                ])),
                ...report.peopleByType.map((item) => DataRow(cells: [
                  DataCell(Text('Type: ${item.label}')),
                  DataCell(Text(item.count.toString())),
                ])),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, WidgetRef ref, Report report) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => ReportPreviewDialog.show(context, report),
            icon: const Icon(Icons.preview_rounded),
            label: const Text('Aperçu'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: FilledButton.icon(
            onPressed: () => _showExportDialog(context, ref, report),
            icon: const Icon(Icons.file_download_rounded),
            label: const Text('Exporter'),
          ),
        ),
      ],
    );
  }

  void _showExportDialog(BuildContext context, WidgetRef ref, Report report) {
    ReportExportDialog.show(context, report);
  }
}
