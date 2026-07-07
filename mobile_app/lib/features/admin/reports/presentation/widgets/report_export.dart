import 'dart:io';

import 'package:excel/excel.dart' as excel;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/report_entity.dart';

/// Generates a PDF file for the given report.
///
/// Returns the file path on success. Throws on error.
Future<String> exportPdf(Report report) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/rapport_${DateTime.now().millisecondsSinceEpoch}.pdf');

  final doc = pw.Document();

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(40),
      header: (context) => pw.Header(
        level: 0,
        child: pw.Text('CSM-GIAS Resto+', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
      ),
      footer: (context) => pw.Container(
        alignment: pw.Alignment.center,
        child: pw.Text('Page ${context.pageNumber}', style: const pw.TextStyle(fontSize: 10)),
      ),
      build: (context) => [
        pw.Header(level: 1, text: 'Rapport de statistiques'),
        pw.Paragraph(text: 'Généré le ${report.generatedAt}'),
        pw.SizedBox(height: 20),
        pw.Header(level: 2, text: 'Filtres'),
        pw.TableHelper.fromTextArray(
          headers: ['Période', 'Du', 'Au'],
          data: [
            [report.periodLabel, report.dateFrom, report.dateTo],
          ],
          border: pw.TableBorder.all(),
        ),
        pw.SizedBox(height: 20),
        pw.Header(level: 2, text: 'Vue d\'ensemble'),
        pw.TableHelper.fromTextArray(
          headers: ['Métrique', 'Valeur'],
          data: [
            ['Repas servis', report.overview.totalMeals.toString()],
            ['Employés', report.overview.totalEmployees.toString()],
            ['Stagiaires', report.overview.totalInterns.toString()],
            ['Visiteurs', report.overview.totalVisitors.toString()],
            ['QR Code', report.overview.qrRegistrations.toString()],
            ['Reconnaissance faciale', report.overview.faceRegistrations.toString()],
            if (report.overview.peakHour != null) ['Heure de pointe', report.overview.peakHour!],
            if (report.overview.mostSelectedMeal != null) ['Repas le plus choisi', report.overview.mostSelectedMeal!],
          ],
          border: pw.TableBorder.all(),
        ),
        pw.SizedBox(height: 20),
        if (report.mealsPerDay.isNotEmpty) ...[
          pw.Header(level: 2, text: 'Repas par période'),
          pw.TableHelper.fromTextArray(
            headers: ['Période', 'Nombre'],
            data: report.mealsPerDay.map((e) => [e.period, e.count.toString()]).toList(),
            border: pw.TableBorder.all(),
          ),
          pw.SizedBox(height: 20),
        ],
        if (report.mealsByHour.isNotEmpty) ...[
          pw.Header(level: 2, text: 'Répartition horaire'),
          pw.TableHelper.fromTextArray(
            headers: ['Heure', 'Nombre'],
            data: report.mealsByHour.map((e) => ['${e.hour}h', e.count.toString()]).toList(),
            border: pw.TableBorder.all(),
          ),
          pw.SizedBox(height: 20),
        ],
        if (report.mealsByCategory.isNotEmpty) ...[
          pw.Header(level: 2, text: 'Par catégorie'),
          pw.TableHelper.fromTextArray(
            headers: ['Catégorie', 'Nombre'],
            data: report.mealsByCategory.map((e) => [e.label, e.count.toString()]).toList(),
            border: pw.TableBorder.all(),
          ),
          pw.SizedBox(height: 20),
        ],
        if (report.registrationMethods.isNotEmpty) ...[
          pw.Header(level: 2, text: 'Méthodes d\'enregistrement'),
          pw.TableHelper.fromTextArray(
            headers: ['Méthode', 'Nombre'],
            data: report.registrationMethods.map((e) => [e.label, e.count.toString()]).toList(),
            border: pw.TableBorder.all(),
          ),
          pw.SizedBox(height: 20),
        ],
        if (report.peopleByType.isNotEmpty) ...[
          pw.Header(level: 2, text: 'Par type de personne'),
          pw.TableHelper.fromTextArray(
            headers: ['Type', 'Nombre'],
            data: report.peopleByType.map((e) => [e.label, e.count.toString()]).toList(),
            border: pw.TableBorder.all(),
          ),
        ],
      ],
    ),
  );

  await file.writeAsBytes(await doc.save());
  return file.path;
}

/// Generates an Excel file for the given report.
///
/// Returns the file path on success. Throws on error.
Future<String> exportExcel(Report report) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/rapport_${DateTime.now().millisecondsSinceEpoch}.xlsx');

  final workbook = excel.Excel.createExcel();
  final sheet = workbook['Rapport'];
  var row = 0;

  void writeRow(List<String> values) {
    for (var i = 0; i < values.length; i++) {
      sheet.cell(excel.CellIndex.indexByColumnRow(columnIndex: i, rowIndex: row)).value = excel.TextCellValue(values[i]);
    }
    row++;
  }

  writeRow(['CSM-GIAS Resto+ - Rapport de statistiques']);
  writeRow(['Généré le ${report.generatedAt}']);
  writeRow([]);

  writeRow(['Filtres']);
  writeRow(['Période', report.periodLabel]);
  writeRow(['Du', report.dateFrom]);
  writeRow(['Au', report.dateTo]);
  writeRow([]);

  writeRow(['Vue d\'ensemble']);
  writeRow(['Métrique', 'Valeur']);
  writeRow(['Repas servis', report.overview.totalMeals.toString()]);
  writeRow(['Employés', report.overview.totalEmployees.toString()]);
  writeRow(['Stagiaires', report.overview.totalInterns.toString()]);
  writeRow(['Visiteurs', report.overview.totalVisitors.toString()]);
  writeRow(['QR Code', report.overview.qrRegistrations.toString()]);
  writeRow(['Reconnaissance faciale', report.overview.faceRegistrations.toString()]);
  if (report.overview.peakHour != null) writeRow(['Heure de pointe', report.overview.peakHour!]);
  if (report.overview.mostSelectedMeal != null) writeRow(['Repas le plus choisi', report.overview.mostSelectedMeal!]);
  writeRow([]);

  if (report.mealsPerDay.isNotEmpty) {
    writeRow(['Repas par période']);
    writeRow(['Période', 'Nombre']);
    for (final item in report.mealsPerDay) {
      writeRow([item.period, item.count.toString()]);
    }
    writeRow([]);
  }

  if (report.mealsByHour.isNotEmpty) {
    writeRow(['Répartition horaire']);
    writeRow(['Heure', 'Nombre']);
    for (final item in report.mealsByHour) {
      writeRow(['${item.hour}h', item.count.toString()]);
    }
    writeRow([]);
  }

  if (report.mealsByCategory.isNotEmpty) {
    writeRow(['Par catégorie']);
    writeRow(['Catégorie', 'Nombre']);
    for (final item in report.mealsByCategory) {
      writeRow([item.label, item.count.toString()]);
    }
    writeRow([]);
  }

  if (report.registrationMethods.isNotEmpty) {
    writeRow(['Méthodes d\'enregistrement']);
    writeRow(['Méthode', 'Nombre']);
    for (final item in report.registrationMethods) {
      writeRow([item.label, item.count.toString()]);
    }
    writeRow([]);
  }

  if (report.peopleByType.isNotEmpty) {
    writeRow(['Par type de personne']);
    writeRow(['Type', 'Nombre']);
    for (final item in report.peopleByType) {
      writeRow([item.label, item.count.toString()]);
    }
  }

  await file.writeAsBytes(workbook.encode()!);
  return file.path;
}

/// Generates a CSV file for the given report.
///
/// Returns the file path on success. Throws on error.
Future<String> exportCsv(Report report) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/rapport_${DateTime.now().millisecondsSinceEpoch}.csv');

  final csv = StringBuffer();
  _csvLine(csv, ['CSM-GIAS Resto+ - Rapport de statistiques']);
  _csvLine(csv, ['Généré le ${report.generatedAt}']);
  _csvLine(csv, []);
  _csvLine(csv, ['Filtres']);
  _csvLine(csv, ['Période', report.periodLabel]);
  _csvLine(csv, ['Du', report.dateFrom]);
  _csvLine(csv, ['Au', report.dateTo]);
  _csvLine(csv, []);
  _csvLine(csv, ['Vue d\'ensemble']);
  _csvLine(csv, ['Métrique', 'Valeur']);
  _csvLine(csv, ['Repas servis', report.overview.totalMeals.toString()]);
  _csvLine(csv, ['Employés', report.overview.totalEmployees.toString()]);
  _csvLine(csv, ['Stagiaires', report.overview.totalInterns.toString()]);
  _csvLine(csv, ['Visiteurs', report.overview.totalVisitors.toString()]);
  _csvLine(csv, ['QR Code', report.overview.qrRegistrations.toString()]);
  _csvLine(csv, ['Reconnaissance faciale', report.overview.faceRegistrations.toString()]);
  if (report.overview.peakHour != null) _csvLine(csv, ['Heure de pointe', report.overview.peakHour!]);
  if (report.overview.mostSelectedMeal != null) _csvLine(csv, ['Repas le plus choisi', report.overview.mostSelectedMeal!]);
  _csvLine(csv, []);

  if (report.mealsPerDay.isNotEmpty) {
    _csvLine(csv, ['Repas par période']);
    _csvLine(csv, ['Période', 'Nombre']);
    for (final item in report.mealsPerDay) {
      _csvLine(csv, [item.period, item.count.toString()]);
    }
    _csvLine(csv, []);
  }

  if (report.mealsByHour.isNotEmpty) {
    _csvLine(csv, ['Répartition horaire']);
    _csvLine(csv, ['Heure', 'Nombre']);
    for (final item in report.mealsByHour) {
      _csvLine(csv, ['${item.hour}h', item.count.toString()]);
    }
    _csvLine(csv, []);
  }

  if (report.mealsByCategory.isNotEmpty) {
    _csvLine(csv, ['Par catégorie']);
    _csvLine(csv, ['Catégorie', 'Nombre']);
    for (final item in report.mealsByCategory) {
      _csvLine(csv, [item.label, item.count.toString()]);
    }
    _csvLine(csv, []);
  }

  if (report.registrationMethods.isNotEmpty) {
    _csvLine(csv, ['Méthodes d\'enregistrement']);
    _csvLine(csv, ['Méthode', 'Nombre']);
    for (final item in report.registrationMethods) {
      _csvLine(csv, [item.label, item.count.toString()]);
    }
    _csvLine(csv, []);
  }

  if (report.peopleByType.isNotEmpty) {
    _csvLine(csv, ['Par type de personne']);
    _csvLine(csv, ['Type', 'Nombre']);
    for (final item in report.peopleByType) {
      _csvLine(csv, [item.label, item.count.toString()]);
    }
  }

  await file.writeAsString(csv.toString());
  return file.path;
}

void _csvLine(StringBuffer buffer, List<String> values) {
  buffer.writeln(values.map((v) {
    if (v.contains(',') || v.contains('"') || v.contains('\n')) {
      return '"${v.replaceAll('"', '""')}"';
    }
    return v;
  }).join(','));
}

/// Shares a file using the system share sheet.
Future<void> shareFile(String filePath) async {
  await Share.shareXFiles([XFile(filePath)], text: 'Rapport CSM-GIAS Resto+');
}

/// Prints a file using the system print dialog.
Future<void> printFile(String filePath) async {
  final file = File(filePath);
  final bytes = await file.readAsBytes();
  await Printing.sharePdf(bytes: bytes);
}

/// Dialog widget that presents export format options.
class ReportExportDialog extends StatelessWidget {
  final Report report;
  final ValueNotifier<bool> isExporting;

  const ReportExportDialog({super.key, required this.report, required this.isExporting});

  static Future<void> show(BuildContext context, Report report) {
    final isExporting = ValueNotifier<bool>(false);
    return showDialog(
      context: context,
      builder: (context) => ReportExportDialog(report: report, isExporting: isExporting),
    );
  }

  Future<void> _export(BuildContext context, String format, Future<String> Function(Report) exportFn) async {
    isExporting.value = true;
    try {
      final path = await exportFn(report);
      isExporting.value = false;
      if (context.mounted) {
        Navigator.of(context).pop();
        _showExportActions(context, path, format);
      }
    } catch (e) {
      isExporting.value = false;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur d\'export $format : $e')),
        );
      }
    }
  }

  void _showExportActions(BuildContext context, String filePath, String format) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share_rounded),
              title: const Text('Partager'),
              subtitle: Text('Fichier $format'),
              onTap: () {
                Navigator.of(ctx).pop();
                shareFile(filePath);
              },
            ),
            ListTile(
              leading: const Icon(Icons.print_rounded),
              title: const Text('Imprimer'),
              subtitle: Text('Fichier $format'),
              onTap: () {
                Navigator.of(ctx).pop();
                printFile(filePath);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Exporter le rapport'),
      content: ValueListenableBuilder<bool>(
        valueListenable: isExporting,
        builder: (context, exporting, child) {
          if (exporting) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ExportOption(
                icon: Icons.picture_as_pdf_rounded,
                label: 'PDF',
                subtitle: 'Document formaté avec tableaux',
                color: Colors.red,
                onTap: () => _export(context, 'PDF', exportPdf),
              ),
              const Divider(height: 1),
              _ExportOption(
                icon: Icons.table_chart_rounded,
                label: 'Excel',
                subtitle: 'Fichier .xlsx modifiable',
                color: Colors.green,
                onTap: () => _export(context, 'Excel', exportExcel),
              ),
              const Divider(height: 1),
              _ExportOption(
                icon: Icons.description_rounded,
                label: 'CSV',
                subtitle: 'Fichier texte avec séparateurs',
                color: theme.colorScheme.primary,
                onTap: () => _export(context, 'CSV', exportCsv),
              ),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: isExporting.value ? null : () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
      ],
    );
  }
}

class _ExportOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ExportOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label),
      subtitle: Text(subtitle),
      onTap: onTap,
    );
  }
}
