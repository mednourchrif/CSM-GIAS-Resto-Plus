import 'package:dio/dio.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../shared/models/result.dart';
import '../../../../../shared/utils/dio_error_mapper.dart';
import '../../data/datasources/audit_remote_datasource.dart';
import '../../domain/entities/audit_log.dart';
import '../../domain/repositories/audit_repository.dart';

class AuditRepositoryImpl implements AuditRepository {
  final AuditRemoteDataSource _dataSource;

  AuditRepositoryImpl({required AuditRemoteDataSource dataSource}) : _dataSource = dataSource;

  @override
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
  }) async {
    try {
      final dto = await _dataSource.getAuditLogs(
        page: page,
        pageSize: pageSize,
        dateFrom: dateFrom,
        dateTo: dateTo,
        userUuid: userUuid,
        role: role,
        action: action,
        entityType: entityType,
        status: status,
        search: search,
      );
      return Success(AuditLogListResponse(
        items: dto.items.map((e) => e.toDomain()).toList(),
        total: dto.total,
        page: dto.page,
        pageSize: dto.pageSize,
        totalPages: dto.totalPages,
      ));
    } on DioException catch (e) {
      return Fail(mapDioError(e, resourceName: 'audit'));
    } catch (e) {
      return Fail(ApiFailure(message: 'Erreur lors du chargement des logs d\'audit.'));
    }
  }

  @override
  Future<Result<AuditLog>> getAuditLog(String uuid) async {
    try {
      final dto = await _dataSource.getAuditLog(uuid);
      return Success(dto.toDomain());
    } on DioException catch (e) {
      return Fail(mapDioError(e, resourceName: "log d'audit"));
    } catch (e) {
      return Fail(ApiFailure(message: "Erreur lors du chargement du log d'audit."));
    }
  }

  @override
  Future<Result<AuditLogFilterValues>> getFilterValues() async {
    try {
      final dto = await _dataSource.getFilterValues();
      return Success(dto.toDomain());
    } on DioException catch (e) {
      return Fail(mapDioError(e, resourceName: 'filtres audit'));
    } catch (e) {
      return Fail(ApiFailure(message: 'Erreur lors du chargement des filtres.'));
    }
  }

  @override
  Future<Result<List<AuditLogExportItem>>> exportAuditLogs({
    DateTime? dateFrom,
    DateTime? dateTo,
    String? userUuid,
    String? role,
    String? action,
    String? entityType,
    String? status,
    String? search,
  }) async {
    try {
      final items = await _dataSource.exportAuditLogs(
        dateFrom: dateFrom,
        dateTo: dateTo,
        userUuid: userUuid,
        role: role,
        action: action,
        entityType: entityType,
        status: status,
        search: search,
      );
      return Success(items.map((e) => e.toDomain()).toList());
    } on DioException catch (e) {
      return Fail(mapDioError(e, resourceName: 'export audit'));
    } catch (e) {
      return Fail(ApiFailure(message: 'Erreur lors de l\'export des logs.'));
    }
  }
}
