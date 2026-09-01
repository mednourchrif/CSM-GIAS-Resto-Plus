import 'package:flutter/foundation.dart';

class Environment {
  Environment._();

  static String get apiBaseUrl {
    const fallback = kIsWeb
        ? 'http://127.0.0.1:4212/api/v1'
        : 'http://10.0.2.2:4212/api/v1';
    const configured = String.fromEnvironment('API_BASE_URL');
    final value = configured.isEmpty ? fallback : configured;
    if (isProduction && configured.isEmpty) {
      throw StateError('API_BASE_URL is required in production.');
    }
    if (isProduction && Uri.tryParse(value)?.scheme != 'https') {
      throw StateError('API_BASE_URL must use HTTPS in production.');
    }
    return value;
  }

  static bool get isProduction => const bool.fromEnvironment('PRODUCTION');

  static String? get tabletApiKey {
    // A shared kiosk credential must never be compiled into a public Web
    // bundle. Browser administration is protected by the user's JWT only.
    if (kIsWeb) return null;

    const key = String.fromEnvironment('TABLET_API_KEY');
    if (isProduction && key.isEmpty) {
      throw StateError('TABLET_API_KEY is required in production.');
    }
    return key.isEmpty ? null : key;
  }

  static bool get isDevelopment => !isProduction;

  static String get environmentName =>
      isProduction ? 'production' : 'development';
}
