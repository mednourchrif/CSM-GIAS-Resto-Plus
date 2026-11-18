import '../../../../../shared/models/result.dart';
import '../entities/setting.dart';

abstract class SettingsRepository {
  Future<Result<AppSettings>> getSettings();
  Future<Result<AppSettings>> getKioskSettings();
  Future<Result<AppSettings>> updateSettings(Map<String, String> settings);
  Future<Result<AppSettings>> resetToDefaults();
  Future<Result<VersionInfo>> getVersion();
  Future<Result<DatabaseStatus>> getDatabaseStatus();
  Future<Result<DatabasePurgeResult>> purgeDatabase({
    required String password,
    required String confirmation,
    bool purgeAuditLogs = false,
  });
}
