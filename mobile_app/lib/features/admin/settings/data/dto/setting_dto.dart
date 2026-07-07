import '../../domain/entities/setting.dart';

class SettingDto {
  final String key;
  final String value;
  final String category;
  final String label;
  final String? description;
  final String fieldType;
  final List<String>? options;
  final String defaultValue;
  final int order;

  const SettingDto({
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

  factory SettingDto.fromJson(Map<String, dynamic> json) => SettingDto(
    key: json['key'] as String,
    value: json['value'] as String,
    category: json['category'] as String,
    label: json['label'] as String,
    description: json['description'] as String?,
    fieldType: json['field_type'] as String,
    options: json['options'] != null ? (json['options'] as List<dynamic>).cast<String>() : null,
    defaultValue: json['default_value'] as String,
    order: json['order'] as int? ?? 0,
  );

  Setting toDomain() => Setting(
    key: key,
    value: value,
    category: category,
    label: label,
    description: description,
    fieldType: fieldType,
    options: options,
    defaultValue: defaultValue,
    order: order,
  );
}

class SettingsGroupDto {
  final String category;
  final String label;
  final List<SettingDto> settings;

  const SettingsGroupDto({required this.category, required this.label, required this.settings});

  factory SettingsGroupDto.fromJson(Map<String, dynamic> json) => SettingsGroupDto(
    category: json['category'] as String,
    label: json['label'] as String,
    settings: (json['settings'] as List<dynamic>)
        .map((e) => SettingDto.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  SettingsGroup toDomain() => SettingsGroup(
    category: category,
    label: label,
    settings: settings.map((e) => e.toDomain()).toList(),
  );
}

class SettingsResponseDto {
  final List<SettingsGroupDto> groups;
  final Map<String, String> raw;

  const SettingsResponseDto({required this.groups, required this.raw});

  factory SettingsResponseDto.fromJson(Map<String, dynamic> json) => SettingsResponseDto(
    groups: (json['groups'] as List<dynamic>)
        .map((e) => SettingsGroupDto.fromJson(e as Map<String, dynamic>))
        .toList(),
    raw: Map<String, String>.from(json['raw'] as Map),
  );

  AppSettings toDomain() => AppSettings(
    groups: groups.map((e) => e.toDomain()).toList(),
    raw: raw,
  );
}

class VersionInfoDto {
  final String applicationVersion;
  final String backendVersion;
  final String environment;

  const VersionInfoDto({
    required this.applicationVersion,
    required this.backendVersion,
    required this.environment,
  });

  factory VersionInfoDto.fromJson(Map<String, dynamic> json) => VersionInfoDto(
    applicationVersion: json['application_version'] as String,
    backendVersion: json['backend_version'] as String,
    environment: json['environment'] as String,
  );

  VersionInfo toDomain() => VersionInfo(
    applicationVersion: applicationVersion,
    backendVersion: backendVersion,
    environment: environment,
  );
}

class DatabaseStatusDto {
  final String status;
  final int totalTables;
  final int totalRecords;

  const DatabaseStatusDto({required this.status, required this.totalTables, required this.totalRecords});

  factory DatabaseStatusDto.fromJson(Map<String, dynamic> json) => DatabaseStatusDto(
    status: json['status'] as String,
    totalTables: json['total_tables'] as int,
    totalRecords: json['total_records'] as int,
  );

  DatabaseStatus toDomain() => DatabaseStatus(
    status: status,
    totalTables: totalTables,
    totalRecords: totalRecords,
  );
}
