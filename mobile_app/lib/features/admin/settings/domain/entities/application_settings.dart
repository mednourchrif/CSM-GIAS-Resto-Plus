import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class ApplicationSettings {
  final String language;
  final String theme;
  final String openingHour;
  final String closingHour;
  final bool faceRecognitionEnabled;
  final bool qrValidationEnabled;
  final String welcomeMessage;
  final String successMessage;
  final int faceDetectionTimeout;
  final int maxRecognitionAttempts;
  final String cameraQuality;
  final int autoReturnDelay;

  const ApplicationSettings({
    this.language = 'fr',
    this.theme = 'system',
    this.openingHour = '12:30',
    this.closingHour = '20:00',
    this.faceRecognitionEnabled = true,
    this.qrValidationEnabled = true,
    this.welcomeMessage = 'Bienvenue',
    this.successMessage = 'Bon appétit',
    this.faceDetectionTimeout = 30,
    this.maxRecognitionAttempts = 3,
    this.cameraQuality = 'high',
    this.autoReturnDelay = 5,
  });

  ThemeMode get themeMode {
    switch (theme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Locale get locale {
    switch (language) {
      case 'en':
        return const Locale('en', 'US');
      case 'ar':
        return const Locale('ar', 'SA');
      default:
        return const Locale('fr', 'FR');
    }
  }

  ResolutionPreset get resolutionPreset {
    switch (cameraQuality) {
      case 'low':
        return ResolutionPreset.low;
      case 'medium':
        return ResolutionPreset.medium;
      case 'high':
        return ResolutionPreset.high;
      default:
        return ResolutionPreset.medium;
    }
  }

  factory ApplicationSettings.fromRawMap(Map<String, String> raw) {
    String _get(String key, String fallback) =>
        raw[key] ?? fallback;

    bool _bool(String key, bool fallback) {
      final v = raw[key];
      if (v == null) return fallback;
      return v.toLowerCase() == 'true';
    }

    int _int(String key, int fallback) {
      final v = raw[key];
      if (v == null) return fallback;
      return int.tryParse(v) ?? fallback;
    }

    return ApplicationSettings(
      language: _get('language', 'fr'),
      theme: _get('theme', 'system'),
      openingHour: _get('opening_hour', '12:30'),
      closingHour: _get('closing_hour', '20:00'),
      faceRecognitionEnabled: _bool('face_recognition_enabled', true),
      qrValidationEnabled: _bool('qr_validation_enabled', true),
      welcomeMessage: _get('welcome_message', 'Bienvenue'),
      successMessage: _get('success_message', 'Bon appétit'),
      faceDetectionTimeout: _int('face_detection_timeout', 30),
      maxRecognitionAttempts: _int('max_recognition_attempts', 3),
      cameraQuality: _get('camera_quality', 'high'),
      autoReturnDelay: _int('auto_return_delay', 5),
    );
  }
}
