import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../providers.dart';
import '../../domain/entities/application_settings.dart';
import 'settings_provider.dart';

final appSettingsProvider = Provider<ApplicationSettings>((ref) {
  final settingsState = ref.watch(settingsProvider);
  final raw = settingsState.settings?.raw ?? {};
  return ApplicationSettings.fromRawMap(raw);
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  return ref.watch(appSettingsProvider).themeMode;
});

final localeProvider = Provider<Locale>((ref) {
  return ref.watch(appSettingsProvider).locale;
});
