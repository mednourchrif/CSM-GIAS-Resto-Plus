import 'package:dio/dio.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../shared/models/result.dart';
import '../../../../../shared/utils/dio_error_mapper.dart';
import '../../domain/entities/face_enrollment_data.dart';
import '../../domain/repositories/face_enrollment_repository.dart';
import '../datasources/face_enrollment_remote_datasource.dart';

class FaceEnrollmentRepositoryImpl implements FaceEnrollmentRepository {
  final FaceEnrollmentRemoteDataSource _dataSource;

  FaceEnrollmentRepositoryImpl({
    required FaceEnrollmentRemoteDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<Result<FaceEnrollmentResult>> enrollFace({
    required String utilisateurUuid,
    required List<String> imagePaths,
  }) async {
    try {
      await _dataSource.enrollFace(
        utilisateurUuid: utilisateurUuid,
        imagePaths: imagePaths,
      );
      return Success(
        FaceEnrollmentResult(
          success: true,
          imagesUploaded: imagePaths.length,
        ),
      );
    } on DioException catch (e) {
      return Fail(mapDioError(e, resourceName: 'enrôlement facial'));
    } catch (e) {
      return Fail(
        const ApiFailure(message: "Erreur lors de l'enrôlement facial."),
      );
    }
  }
}
