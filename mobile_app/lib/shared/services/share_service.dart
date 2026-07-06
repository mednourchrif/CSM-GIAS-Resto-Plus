import 'dart:convert';
import 'dart:io';

import 'package:share_plus/share_plus.dart';

class ShareService {
  static Future<bool> shareQrImage({
    required String base64Image,
    required String ownerName,
    required String typeLabel,
  }) async {
    final cleanData = base64Image.contains(',')
        ? base64Image.split(',').last
        : base64Image;

    final bytes = base64Decode(cleanData);

    final dir = Directory.systemTemp;
    final safeName = ownerName.replaceAll(RegExp(r'\s+'), '');
    final file = File('${dir.path}/QR_$safeName.png');
    await file.writeAsBytes(bytes);

    final message = 'QR Code\n'
        'Propriétaire : $ownerName\n'
        'Type : $typeLabel\n'
        'Généré par : CSM-GIAS Resto+';

    final result = await Share.shareXFiles(
      [XFile(file.path)],
      text: message,
    );

    return result.status == ShareResultStatus.success;
  }
}
