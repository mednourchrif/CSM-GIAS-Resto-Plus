import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

class DownloadService {
  static const _channel = MethodChannel('com.example.mobile_app/download');

  static Future<String?> saveQrToDownloads({
    required String fileName,
    required String base64Image,
  }) async {
    if (Platform.isAndroid) {
      try {
        final path = await _channel.invokeMethod<String>('saveToDownloads', {
          'fileName': fileName,
          'base64Data': base64Image,
        });
        return path;
      } on MissingPluginException {
        return null;
      } catch (e) {
        return null;
      }
    } else if (Platform.isIOS) {
      final dir = Directory.systemTemp;
      final file = File('${dir.path}/$fileName');
      final cleanData = base64Image.contains(',')
          ? base64Image.split(',').last
          : base64Image;
      await file.writeAsBytes(base64Decode(cleanData));
      return file.path;
    } else {
      final dir = Directory.systemTemp;
      final file = File('${dir.path}/$fileName');
      final cleanData = base64Image.contains(',')
          ? base64Image.split(',').last
          : base64Image;
      await file.writeAsBytes(base64Decode(cleanData));
      return file.path;
    }
  }
}
