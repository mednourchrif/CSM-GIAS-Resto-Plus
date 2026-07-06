import 'package:dio/dio.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../shared/models/result.dart';
import '../../../../../shared/utils/dio_error_mapper.dart';
import '../../domain/entities/qr_code.dart';
import '../../domain/repositories/qr_repository.dart';
import '../datasources/qr_remote_datasource.dart';

class QrRepositoryImpl implements QrRepository {
  final QrRemoteDataSource _dataSource;

  QrRepositoryImpl({required QrRemoteDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Result<PaginatedQrCodes>> getQrCodes({
    required int page,
    required int pageSize,
    String? search,
    String? typeFilter,
    String? statusFilter,
    String? sort,
    String? order,
  }) async {
    try {
      final response = await _dataSource.getQrCodes(
        page: page,
        pageSize: pageSize,
        search: search,
        typeFilter: typeFilter,
        statusFilter: statusFilter,
        sort: sort,
        order: order,
      );
      return Success(PaginatedQrCodes(
        items: response.items.map((e) => e.toDomain()).toList(),
        total: response.total,
        page: response.page,
        pageSize: response.pageSize,
        totalPages: response.totalPages,
      ));
    } on DioException catch (e) {
      return Fail(mapDioError(e, resourceName: 'QR code'));
    } catch (e) {
      return Fail(ApiFailure(message: 'Erreur lors du chargement des QR codes.'));
    }
  }

  @override
  Future<Result<QrCode>> getQrCode(String uuid) async {
    try {
      final dto = await _dataSource.getQrCode(uuid);
      return Success(dto.toDomain());
    } on DioException catch (e) {
      return Fail(mapDioError(e, resourceName: 'QR code'));
    } catch (e) {
      return Fail(ApiFailure(message: 'Erreur lors du chargement du QR code.'));
    }
  }

  @override
  Future<Result<QrCode>> generateInternQr(String internUuid) async {
    try {
      final dto = await _dataSource.generateInternQr(internUuid);
      return Success(dto.toDomain());
    } on DioException catch (e) {
      return Fail(mapDioError(e, resourceName: 'QR code'));
    } catch (e) {
      return Fail(ApiFailure(message: 'Erreur lors de la génération du QR.'));
    }
  }

  @override
  Future<Result<QrCode>> generateVisitorQr(String visitorUuid) async {
    try {
      final dto = await _dataSource.generateVisitorQr(visitorUuid);
      return Success(dto.toDomain());
    } on DioException catch (e) {
      return Fail(mapDioError(e, resourceName: 'QR code'));
    } catch (e) {
      return Fail(ApiFailure(message: 'Erreur lors de la génération du QR.'));
    }
  }

  @override
  Future<Result<QrCode>> revokeQr(String uuid) async {
    try {
      final dto = await _dataSource.revokeQr(uuid);
      return Success(dto.toDomain());
    } on DioException catch (e) {
      return Fail(mapDioError(e, resourceName: 'QR code'));
    } catch (e) {
      return Fail(ApiFailure(message: 'Erreur lors de la révocation du QR.'));
    }
  }

  @override
  Future<Result<QrCode>> regenerateQr(String ownerUuid,
      {String ownerType = 'STAGIAIRE'}) async {
    try {
      final dto = await _dataSource.regenerateQr(ownerUuid, ownerType: ownerType);
      return Success(dto.toDomain());
    } on DioException catch (e) {
      return Fail(mapDioError(e, resourceName: 'QR code'));
    } catch (e) {
      return Fail(ApiFailure(message: 'Erreur lors de la régénération du QR.'));
    }
  }

  @override
  Future<Result<List<int>>> downloadQr(String uuid) async {
    try {
      final bytes = await _dataSource.downloadQr(uuid);
      return Success(bytes);
    } on DioException catch (e) {
      return Fail(mapDioError(e, resourceName: 'QR code'));
    } catch (e) {
      return Fail(ApiFailure(message: 'Erreur lors du téléchargement du QR.'));
    }
  }

  @override
  Future<Result<List<QrCode>>> getQrHistory(String ownerUuid) async {
    try {
      final dtos = await _dataSource.getQrHistory(ownerUuid);
      return Success(dtos.map((e) => e.toDomain()).toList());
    } on DioException catch (e) {
      return Fail(mapDioError(e, resourceName: 'QR code'));
    } catch (e) {
      return Fail(ApiFailure(message: 'Erreur lors du chargement de l\'historique.'));
    }
  }
}
