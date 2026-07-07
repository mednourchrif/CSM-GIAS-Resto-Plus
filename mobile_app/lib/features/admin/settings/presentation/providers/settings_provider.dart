import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../providers.dart';
import '../../data/datasources/settings_remote_datasource.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/repositories/settings_repository.dart';
import 'settings_state.dart';

final settingsRemoteDataSourceProvider = Provider<SettingsRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SettingsRemoteDataSource(dio: apiClient.dio);
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(dataSource: ref.watch(settingsRemoteDataSourceProvider));
});

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier(ref.watch(settingsRepositoryProvider));
});

class SettingsNotifier extends StateNotifier<SettingsState> {
  final SettingsRepository _repository;

  SettingsNotifier(this._repository) : super(const SettingsState());

  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _repository.getSettings();
    result.when(
      success: (settings) {
        state = state.copyWith(isLoading: false, settings: settings);
      },
      failure: (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
      },
    );
  }

  void updateValue(String key, String value) {
    final pending = Map<String, String>.from(state.pendingChanges);
    pending[key] = value;
    state = state.copyWith(pendingChanges: pending);
  }

  Future<void> saveChanges() async {
    if (!state.hasUnsavedChanges) return;
    state = state.copyWith(isSaving: true, clearError: true);
    final result = await _repository.updateSettings(state.pendingChanges);
    result.when(
      success: (settings) {
        state = state.copyWith(
          isSaving: false,
          settings: settings,
          clearPendingChanges: true,
          successMessage: 'Paramètres enregistrés avec succès.',
        );
      },
      failure: (failure) {
        state = state.copyWith(isSaving: false, error: failure.message);
      },
    );
  }

  Future<void> resetToDefaults() async {
    state = state.copyWith(isResetting: true);
    final result = await _repository.resetToDefaults();
    result.when(
      success: (settings) {
        state = state.copyWith(
          isResetting: false,
          settings: settings,
          clearPendingChanges: true,
          successMessage: 'Paramètres réinitialisés avec succès.',
        );
      },
      failure: (failure) {
        state = state.copyWith(isResetting: false, error: failure.message);
      },
    );
  }

  Future<void> loadVersion() async {
    final result = await _repository.getVersion();
    result.when(
      success: (version) => state = state.copyWith(version: version),
      failure: (_) {},
    );
  }

  Future<void> loadDatabaseStatus() async {
    final result = await _repository.getDatabaseStatus();
    result.when(
      success: (status) => state = state.copyWith(databaseStatus: status),
      failure: (_) {},
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void clearSuccessMessage() {
    state = state.copyWith(clearSuccessMessage: true);
  }
}
