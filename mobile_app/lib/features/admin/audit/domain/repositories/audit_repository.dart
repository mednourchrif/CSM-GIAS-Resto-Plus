import '../../../../../shared/models/result.dart';
import '../entities/audit_log.dart';

abstract class AuditRepository {
  Future<Result<AuditLogListResponse>> getAuditLogs({
    required int page,
    required int pageSize,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? userUuid,
    String? role,
    String? action,
    String? entityType,
    String? status,
    String? search,
  });

  Future<Result<AuditLog>> getAuditLog(String uuid);

  Future<Result<AuditLogFilterValues>> getFilterValues();

  Future<Result<List<AuditLogExportItem>>> exportAuditLogs({
    DateTime? dateFrom,
    DateTime? dateTo,
    String? userUuid,
    String? role,
    String? action,
    String? entityType,
    String? status,
    String? search,
  });
}

class AuditLogListResponse {
  final List<AuditLog> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  const AuditLogListResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  bool get hasMore => page < totalPages;
}
