import '../../domain/entities/setting.dart';

class SettingsState {
  final bool isLoading;
  final bool isSaving;
  final AppSettings? settings;
  final VersionInfo? version;
  final DatabaseStatus? databaseStatus;
  final Map<String, String> pendingChanges;
  final String? error;
  final String? successMessage;
  final bool isResetting;

  const SettingsState({
    this.isLoading = false,
    this.isSaving = false,
    this.settings,
    this.version,
    this.databaseStatus,
    this.pendingChanges = const {},
    this.error,
    this.successMessage,
    this.isResetting = false,
  });

  bool get hasUnsavedChanges => pendingChanges.isNotEmpty;

  SettingsState copyWith({
    bool? isLoading,
    bool? isSaving,
    AppSettings? settings,
    VersionInfo? version,
    DatabaseStatus? databaseStatus,
    Map<String, String>? pendingChanges,
    bool clearPendingChanges = false,
    String? error,
    bool clearError = false,
    String? successMessage,
    bool clearSuccessMessage = false,
    bool? isResetting,
  }) {
    return SettingsState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      settings: settings ?? this.settings,
      version: version ?? this.version,
      databaseStatus: databaseStatus ?? this.databaseStatus,
      pendingChanges: clearPendingChanges ? {} : (pendingChanges ?? this.pendingChanges),
      error: clearError ? null : (error ?? this.error),
      successMessage: clearSuccessMessage ? null : (successMessage ?? this.successMessage),
      isResetting: isResetting ?? this.isResetting,
    );
  }
}
