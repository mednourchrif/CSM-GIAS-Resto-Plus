import 'package:dio/dio.dart';

import '../../../../core/errors/failures.dart';
import '../../../../shared/models/result.dart';
import '../../../../shared/utils/dio_error_mapper.dart';
import '../../domain/entities/face_recognition_result.dart';
import '../../domain/repositories/face_recognition_repository.dart';
import '../datasources/face_recognition_remote_datasource.dart';

class FaceRecognitionRepositoryImpl implements FaceRecognitionRepository {
  final FaceRecognitionRemoteDataSource _remoteDataSource;

  FaceRecognitionRepositoryImpl({required this._remoteDataSource});

  @override
  Future<Result<FaceRecognitionResult>> identify({
    required String imageBase64,
  }) async {
    try {
      final response = await _remoteDataSource.identify(
        imageBase64: imageBase64,
      );
      return Success(response.toDomain());
    } on DioException catch (e) {
      return Fail(mapDioError(e, resourceName: 'visage'));
    } catch (e) {
      return const Fail(
        ApiFailure(message: 'Erreur lors de l\'identification faciale.'),
      );
    }
  }
}
