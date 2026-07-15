import 'package:dio/dio.dart';

import '../dto/audit_log_dto.dart';

class AuditLogListDto {
  final List<AuditLogDto> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  const AuditLogListDto({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });
}

class AuditRemoteDataSource {
  final Dio _dio;

  AuditRemoteDataSource({required Dio dio}) : _dio = dio;

  Future<AuditLogListDto> getAuditLogs({
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
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
      if (dateFrom != null) 'date_from': dateFrom.toIso8601String(),
      if (dateTo != null) 'date_to': dateTo.toIso8601String(),
      if (userUuid != null && userUuid.isNotEmpty) 'user_uuid': userUuid,
      if (role != null && role.isNotEmpty) 'role': role,
      if (action != null && action.isNotEmpty) 'action': action,
      if (entityType != null && entityType.isNotEmpty) 'entity_type': entityType,
      if (status != null && status.isNotEmpty) 'status': status,
      if (search != null && search.isNotEmpty) 'search': search,
    };
    final response = await _dio.get<Map<String, dynamic>>(
      '/audit',
      queryParameters: queryParams,
    );
    final body = response.data!;
    final data = (body['data'] as List<dynamic>)
        .map((e) => AuditLogDto.fromJson(e as Map<String, dynamic>))
        .toList();
    return AuditLogListDto(
      items: data,
      total: body['total'] as int,
      page: body['page'] as int,
      pageSize: body['page_size'] as int,
      totalPages: body['total_pages'] as int,
    );
  }

  Future<AuditLogDto> getAuditLog(String uuid) async {
    final response = await _dio.get<Map<String, dynamic>>('/audit/$uuid');
    return AuditLogDto.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  Future<AuditLogFilterValuesDto> getFilterValues() async {
    final response = await _dio.get<Map<String, dynamic>>('/audit/filters');
    return AuditLogFilterValuesDto.fromJson(response.data!['data'] as Map<String, dynamic>);
  }

  Future<List<AuditLogExportItemDto>> exportAuditLogs({
    DateTime? dateFrom,
    DateTime? dateTo,
    String? userUuid,
    String? role,
    String? action,
    String? entityType,
    String? status,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{
      if (dateFrom != null) 'date_from': dateFrom.toIso8601String(),
      if (dateTo != null) 'date_to': dateTo.toIso8601String(),
      if (userUuid != null && userUuid.isNotEmpty) 'user_uuid': userUuid,
      if (role != null && role.isNotEmpty) 'role': role,
      if (action != null && action.isNotEmpty) 'action': action,
      if (entityType != null && entityType.isNotEmpty) 'entity_type': entityType,
      if (status != null && status.isNotEmpty) 'status': status,
      if (search != null && search.isNotEmpty) 'search': search,
    };
    final response = await _dio.get<Map<String, dynamic>>(
      '/audit/export',
      queryParameters: queryParams,
    );
    final data = response.data!['data'] as List<dynamic>;
    return data
        .map((e) => AuditLogExportItemDto.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
