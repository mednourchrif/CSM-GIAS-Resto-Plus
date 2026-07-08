import '../../domain/entities/audit_log.dart';

class AuditLogDto {
  final int id;
  final String uuid;
  final DateTime timestamp;
  final String? userUuid;
  final String userName;
  final String userRole;
  final String action;
  final String? entityType;
  final String? entityUuid;
  final String? entityName;
  final String? description;
  final String? httpMethod;
  final String? endpoint;
  final String? ipAddress;
  final String? userAgent;
  final String status;
  final String? metadataJson;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AuditLogDto({
    required this.id,
    required this.uuid,
    required this.timestamp,
    this.userUuid,
    required this.userName,
    required this.userRole,
    required this.action,
    this.entityType,
    this.entityUuid,
    this.entityName,
    this.description,
    this.httpMethod,
    this.endpoint,
    this.ipAddress,
    this.userAgent,
    required this.status,
    this.metadataJson,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AuditLogDto.fromJson(Map<String, dynamic> json) {
    return AuditLogDto(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      userUuid: json['user_uuid'] as String?,
      userName: json['user_name'] as String,
      userRole: json['user_role'] as String,
      action: json['action'] as String,
      entityType: json['entity_type'] as String?,
      entityUuid: json['entity_uuid'] as String?,
      entityName: json['entity_name'] as String?,
      description: json['description'] as String?,
      httpMethod: json['http_method'] as String?,
      endpoint: json['endpoint'] as String?,
      ipAddress: json['ip_address'] as String?,
      userAgent: json['user_agent'] as String?,
      status: json['status'] as String? ?? 'SUCCESS',
      metadataJson: json['metadata_json'] as String?,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? DateTime.now(),
    );
  }

  AuditLog toDomain() => AuditLog(
    id: id,
    uuid: uuid,
    timestamp: timestamp,
    userUuid: userUuid,
    userName: userName,
    userRole: userRole,
    action: action,
    entityType: entityType,
    entityUuid: entityUuid,
    entityName: entityName,
    description: description,
    httpMethod: httpMethod,
    endpoint: endpoint,
    ipAddress: ipAddress,
    userAgent: userAgent,
    status: status,
    metadataJson: metadataJson,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

class AuditLogFilterValuesDto {
  final List<String> actions;
  final List<String> entityTypes;

  const AuditLogFilterValuesDto({required this.actions, required this.entityTypes});

  factory AuditLogFilterValuesDto.fromJson(Map<String, dynamic> json) {
    return AuditLogFilterValuesDto(
      actions: (json['actions'] as List<dynamic>).map((e) => e as String).toList(),
      entityTypes: (json['entity_types'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }

  AuditLogFilterValues toDomain() => AuditLogFilterValues(
    actions: actions,
    entityTypes: entityTypes,
  );
}

class AuditLogExportItemDto {
  final DateTime timestamp;
  final String userName;
  final String userRole;
  final String action;
  final String? entityType;
  final String? entityName;
  final String? description;
  final String status;

  const AuditLogExportItemDto({
    required this.timestamp,
    required this.userName,
    required this.userRole,
    required this.action,
    this.entityType,
    this.entityName,
    this.description,
    required this.status,
  });

  factory AuditLogExportItemDto.fromJson(Map<String, dynamic> json) {
    return AuditLogExportItemDto(
      timestamp: DateTime.parse(json['timestamp'] as String),
      userName: json['user_name'] as String,
      userRole: json['user_role'] as String,
      action: json['action'] as String,
      entityType: json['entity_type'] as String?,
      entityName: json['entity_name'] as String?,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'SUCCESS',
    );
  }

  AuditLogExportItem toDomain() => AuditLogExportItem(
    timestamp: timestamp,
    userName: userName,
    userRole: userRole,
    action: action,
    entityType: entityType,
    entityName: entityName,
    description: description,
    status: status,
  );
}
