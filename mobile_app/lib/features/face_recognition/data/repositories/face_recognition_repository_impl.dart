import 'package:dio/dio.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/models/result.dart';
import '../../../../shared/utils/dio_error_mapper.dart';
import '../../domain/entities/face_recognition_result.dart';
import '../../domain/repositories/face_recognition_repository.dart';
import '../datasources/face_recognition_remote_datasource.dart';

class FaceRecognitionRepositoryImpl implements FaceRecognitionRepository {
  final FaceRecognitionRemoteDataSource _remoteDataSource;

  FaceRecognitionRepositoryImpl({
    required FaceRecognitionRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<Result<FaceRecognitionResult>> identify({
    required String imageBase64,
    String? categorieUuid,
  }) async {
    try {
      final response = await _remoteDataSource.identify(
        imageBase64: imageBase64,
        categorieUuid: categorieUuid,
      );
      return Success(response.toDomain());
    } on DioException catch (e) {
      return Fail(mapDioError(e, resourceName: 'visage'));
    } catch (e) {
      return Fail(
        const ApiFailure(message: 'Erreur lors de l\'identification faciale.'),
      );

    }
  }
}
