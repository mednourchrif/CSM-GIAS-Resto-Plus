class AuditLog {
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

  const AuditLog({
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
}

class AuditLogFilterValues {
  final List<String> actions;
  final List<String> entityTypes;

  const AuditLogFilterValues({
    required this.actions,
    required this.entityTypes,
  });
}

class AuditLogExportItem {
  final DateTime timestamp;
  final String userName;
  final String userRole;
  final String action;
  final String? entityType;
  final String? entityName;
  final String? description;
  final String status;

  const AuditLogExportItem({
    required this.timestamp,
    required this.userName,
    required this.userRole,
    required this.action,
    this.entityType,
    this.entityName,
    this.description,
    required this.status,
  });
}
