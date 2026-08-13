import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../domain/entities/receipt.dart';

class ReceiptPrintService {
  final Dio _dio;

  const ReceiptPrintService(this._dio);

  Future<bool> printReceipt(Receipt receipt) async {
    bool printed;
    try {
      printed = await Printing.layoutPdf(
        name: 'Recu_${receipt.number}',
        onLayout: (_) => buildPdf(receipt),
      );
    } catch (_) {
      return false;
    }
    if (!printed) return false;
    try {
      await _dio.post<void>('/receipts/${receipt.uuid}/printed');
    } on DioException {
      // Printing must remain available if print-audit synchronization is
      // temporarily unavailable. The receipt itself is already persisted.
    }
    return true;
  }

  Future<Uint8List> buildPdf(Receipt receipt) async {
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');
    final document = pw.Document(
      title: 'Recu ${receipt.number}',
      author: 'CSM-GIAS Resto+',
    );
    document.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(16),
        build: (_) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.stretch,
          children: [
            pw.Text(
              'CSM-GIAS RESTO+',
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'RECU DE REPAS',
              textAlign: pw.TextAlign.center,
              style: const pw.TextStyle(fontSize: 11),
            ),
            pw.Divider(),
            _row('Recu', receipt.number),
            _row('Date', dateFormat.format(receipt.mealDate)),
            _row('Heure', timeFormat.format(receipt.servedAt.toLocal())),
            pw.Divider(),
            _row('Beneficiaire', receipt.fullName),
            if (receipt.employeeNumber case final value?)
              _row('Matricule', value),
            _row('Profil', receipt.userType),
            pw.Divider(),
            _row('Type plat', receipt.categoryName),
            _row('Identification', receipt.identificationType),
            pw.Divider(),
            pw.Text(
              'Bon appetit',
              textAlign: pw.TextAlign.center,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            if (receipt.qrToken case final token?) ...[
              pw.SizedBox(height: 8),
              pw.BarcodeWidget(
                barcode: pw.Barcode.qrCode(),
                data: token,
                width: 100,
                height: 100,
                drawText: false,
              ),
              pw.SizedBox(height: 3),
              pw.Text('Scanner pour verifier', textAlign: pw.TextAlign.center),
            ],
          ],
        ),
      ),
    );
    return document.save();
  }

  pw.Widget _row(String label, String value) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(
          width: 70,
          child: pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Expanded(child: pw.Text(value)),
      ],
    ),
  );
}
