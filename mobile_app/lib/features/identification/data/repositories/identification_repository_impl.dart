import 'package:dio/dio.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/models/result.dart';
import '../../../../shared/utils/dio_error_mapper.dart';
import '../../domain/entities/identification_grant.dart';
import '../../domain/repositories/identification_repository.dart';
import '../datasources/identification_remote_datasource.dart';

class IdentificationRepositoryImpl implements IdentificationRepository {
  final IdentificationRemoteDataSource _remoteDataSource;

  IdentificationRepositoryImpl({required this._remoteDataSource});

  @override
  Future<Result<IdentificationGrant>> identifyByQr(String qrToken) async {
    try {
      final response = await _remoteDataSource.identifyByQr(qrToken);
      return Success(response.toDomain());
    } on DioException catch (error) {
      return Fail(mapDioError(error, resourceName: 'QR code'));
    } on FormatException catch (error, stackTrace) {
      return Fail(
        ApiFailure(
          message: 'Réponse d’identification invalide.',
          originalError: error,
          stackTrace: stackTrace,
        ),
      );
    } catch (error, stackTrace) {
      return Fail(
        ApiFailure(
          message: 'Impossible de valider ce QR code.',
          originalError: error,
          stackTrace: stackTrace,
        ),
      );
    }
  }
}
