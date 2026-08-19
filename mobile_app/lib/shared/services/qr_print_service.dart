import 'dart:convert';

import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../features/admin/qr/domain/entities/qr_code.dart';
import 'share_service.dart';

class QrPrintService {
  const QrPrintService._();

  static Future<void> printQr(QrCode qr) async {
    final encoded = qr.qrBase64;
    if (encoded == null || encoded.isEmpty) return;
    final bytes = base64Decode(
      encoded.contains(',') ? encoded.split(',').last : encoded,
    );
    await Printing.layoutPdf(
      name: 'QR_${qr.proprietaireFullName}',
      onLayout: (format) async {
        final document = pw.Document();
        document.addPage(
          pw.Page(
            pageFormat: format,
            build: (_) => pw.Center(
              child: pw.Column(
                mainAxisSize: pw.MainAxisSize.min,
                children: [
                  pw.Text(
                    'CSM-GIAS Resto+',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Image(pw.MemoryImage(bytes), width: 220, height: 220),
                  pw.SizedBox(height: 14),
                  pw.Text(
                    qr.proprietaireFullName,
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(qr.typeLabel),
                ],
              ),
            ),
          ),
        );
        return document.save();
      },
    );
  }

  static Future<bool> shareQr(QrCode qr) async {
    final encoded = qr.qrBase64;
    if (encoded == null || encoded.isEmpty) return false;
    return ShareService.shareQrImage(
      base64Image: encoded,
      ownerName: qr.proprietaireFullName,
      typeLabel: qr.typeLabel,
    );
  }
}
