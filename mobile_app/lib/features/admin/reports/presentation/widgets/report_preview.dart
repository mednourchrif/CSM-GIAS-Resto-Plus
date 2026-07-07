import 'package:flutter/material.dart';

import '../../domain/entities/report_entity.dart';
import 'report_charts.dart';
import 'report_overview_cards.dart';

class ReportPreviewDialog extends StatelessWidget {
  final Report report;

  const ReportPreviewDialog({super.key, required this.report});

  static Future<void> show(BuildContext context, Report report) {
    return showDialog(
      context: context,
      useSafeArea: false,
      builder: (context) => Dialog.fullscreen(
        child: ReportPreviewDialog(report: report),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aperçu du rapport'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rapport de statistiques', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              'Généré le ${report.generatedAt}',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Filtres appliqués', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    _FilterRow(label: 'Période', value: report.periodLabel),
                    _FilterRow(label: 'Du', value: report.dateFrom),
                    _FilterRow(label: 'Au', value: report.dateTo),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Vue d\'ensemble', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ReportOverviewCards(overview: report.overview),
            const SizedBox(height: 24),
            Text('Graphiques', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ReportCharts(report: report),
            const SizedBox(height: 24),
            Text('Données détaillées', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            if (report.mealsPerDay.isNotEmpty) ...[
              _DataTableSection(
                title: 'Repas par période',
                columns: const ['Période', 'Nombre'],
                rows: report.mealsPerDay.map((e) => [e.period, e.count.toString()]).toList(),
              ),
              const SizedBox(height: 16),
            ],
            if (report.mealsByHour.isNotEmpty) ...[
              _DataTableSection(
                title: 'Répartition horaire',
                columns: const ['Heure', 'Nombre'],
                rows: report.mealsByHour.map((e) => ['${e.hour}h', e.count.toString()]).toList(),
              ),
              const SizedBox(height: 16),
            ],
            if (report.mealsByCategory.isNotEmpty) ...[
              _DataTableSection(
                title: 'Par catégorie',
                columns: const ['Catégorie', 'Nombre'],
                rows: report.mealsByCategory.map((e) => [e.label, e.count.toString()]).toList(),
              ),
              const SizedBox(height: 16),
            ],
            if (report.registrationMethods.isNotEmpty) ...[
              _DataTableSection(
                title: 'Méthodes d\'enregistrement',
                columns: const ['Méthode', 'Nombre'],
                rows: report.registrationMethods.map((e) => [e.label, e.count.toString()]).toList(),
              ),
              const SizedBox(height: 16),
            ],
            if (report.peopleByType.isNotEmpty) ...[
              _DataTableSection(
                title: 'Par type de personne',
                columns: const ['Type', 'Nombre'],
                rows: report.peopleByType.map((e) => [e.label, e.count.toString()]).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  final String label;
  final String value;

  const _FilterRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }
}

class _DataTableSection extends StatelessWidget {
  final String title;
  final List<String> columns;
  final List<List<String>> rows;

  const _DataTableSection({
    required this.title,
    required this.columns,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Card(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: columns.map((c) => DataColumn(label: Text(c))).toList(),
              rows: rows.map((r) {
                return DataRow(
                  cells: r.map((c) => DataCell(Text(c))).toList(),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
