import 'environment.dart';

class AppConfig {
  AppConfig._();

  static String get apiBaseUrl => Environment.apiBaseUrl;
  static bool get isProduction => Environment.isProduction;
  static bool get isDevelopment => Environment.isDevelopment;
  static String get environmentName => Environment.environmentName;
}
