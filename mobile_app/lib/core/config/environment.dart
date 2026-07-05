import 'package:flutter/foundation.dart';

class Environment {
  Environment._();

  static String get apiBaseUrl {
    const fallback = 'http://localhost:8000/api/v1';
    const key = String.fromEnvironment('API_BASE_URL');
    if (key.isEmpty) {
      debugPrint(
        'Environment: API_BASE_URL not set via --dart-define, '
        'using fallback: $fallback',
      );
      return fallback;
    }
    debugPrint('Environment: API_BASE_URL = $key');
    return key;
  }

  static bool get isProduction => const bool.fromEnvironment('PRODUCTION');

  static bool get isDevelopment => !isProduction;

  static String get environmentName =>
      isProduction ? 'production' : 'development';
}
