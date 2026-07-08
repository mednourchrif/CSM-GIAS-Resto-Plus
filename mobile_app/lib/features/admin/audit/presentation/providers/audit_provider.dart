import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../providers.dart';
import '../../../audit/data/datasources/audit_remote_datasource.dart';
import '../../../audit/data/repositories/audit_repository_impl.dart';
import '../../../audit/domain/entities/audit_log.dart';
import '../../../audit/domain/repositories/audit_repository.dart';

final auditRemoteDataSourceProvider = Provider<AuditRemoteDataSource>((ref) {
  return AuditRemoteDataSource(dio: ref.watch(apiClientProvider).dio);
});

final auditRepositoryProvider = Provider<AuditRepository>((ref) {
  return AuditRepositoryImpl(dataSource: ref.watch(auditRemoteDataSourceProvider));
});

final auditLogsProvider = FutureProvider.family<AuditLogListResponse, AuditQueryParams>((ref, params) async {
  final repo = ref.read(auditRepositoryProvider);
  final result = await repo.getAuditLogs(
    page: params.page,
    pageSize: params.pageSize,
    dateFrom: params.dateFrom,
    dateTo: params.dateTo,
    userUuid: params.userUuid,
    role: params.role,
    action: params.action,
    entityType: params.entityType,
    status: params.status,
    search: params.search,
  );
  return result.when(
    success: (data) => data,
    failure: (f) => throw Exception(f.message),
  );
});

final auditLogDetailProvider = FutureProvider.family<AuditLog, String>((ref, uuid) async {
  final repo = ref.read(auditRepositoryProvider);
  final result = await repo.getAuditLog(uuid);
  return result.when(
    success: (data) => data,
    failure: (f) => throw Exception(f.message),
  );
});

final auditFilterValuesProvider = FutureProvider<AuditLogFilterValues>((ref) async {
  final repo = ref.read(auditRepositoryProvider);
  final result = await repo.getFilterValues();
  return result.when(
    success: (data) => data,
    failure: (f) => throw Exception(f.message),
  );
});

class AuditQueryParams {
  final int page;
  final int pageSize;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? userUuid;
  final String? role;
  final String? action;
  final String? entityType;
  final String? status;
  final String? search;

  const AuditQueryParams({
    this.page = 1,
    this.pageSize = 50,
    this.dateFrom,
    this.dateTo,
    this.userUuid,
    this.role,
    this.action,
    this.entityType,
    this.status,
    this.search,
  });

  AuditQueryParams copyWith({
    int? page,
    int? pageSize,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? userUuid,
    String? role,
    String? action,
    String? entityType,
    String? status,
    String? search,
    bool clearDateFrom = false,
    bool clearDateTo = false,
    bool clearUserUuid = false,
    bool clearRole = false,
    bool clearAction = false,
    bool clearEntityType = false,
    bool clearStatus = false,
    bool clearSearch = false,
  }) {
    return AuditQueryParams(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      dateFrom: clearDateFrom ? null : (dateFrom ?? this.dateFrom),
      dateTo: clearDateTo ? null : (dateTo ?? this.dateTo),
      userUuid: clearUserUuid ? null : (userUuid ?? this.userUuid),
      role: clearRole ? null : (role ?? this.role),
      action: clearAction ? null : (action ?? this.action),
      entityType: clearEntityType ? null : (entityType ?? this.entityType),
      status: clearStatus ? null : (status ?? this.status),
      search: clearSearch ? null : (search ?? this.search),
    );
  }
}
