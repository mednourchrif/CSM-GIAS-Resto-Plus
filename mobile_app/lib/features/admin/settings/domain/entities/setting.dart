class Setting {
  final String key;
  final String value;
  final String category;
  final String label;
  final String? description;
  final String fieldType;
  final List<String>? options;
  final String defaultValue;
  final int order;

  const Setting({
    required this.key,
    required this.value,
    required this.category,
    required this.label,
    this.description,
    required this.fieldType,
    this.options,
    required this.defaultValue,
    this.order = 0,
  });

  bool get isChanged => value != defaultValue;
}

class SettingsGroup {
  final String category;
  final String label;
  final List<Setting> settings;

  const SettingsGroup({
    required this.category,
    required this.label,
    required this.settings,
  });
}

class AppSettings {
  final List<SettingsGroup> groups;
  final Map<String, String> raw;

  const AppSettings({required this.groups, required this.raw});

  String? getValue(String key) => raw[key];
}

class VersionInfo {
  final String applicationVersion;
  final String backendVersion;
  final String environment;

  const VersionInfo({
    required this.applicationVersion,
    required this.backendVersion,
    required this.environment,
  });
}

class DatabaseStatus {
  final String status;
  final int totalTables;
  final int totalRecords;

  const DatabaseStatus({
    required this.status,
    required this.totalTables,
    required this.totalRecords,
  });

  bool get isConnected => status == 'connected';
}
