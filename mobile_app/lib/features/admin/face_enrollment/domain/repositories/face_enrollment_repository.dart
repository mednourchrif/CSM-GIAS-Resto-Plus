import '../../../../../shared/models/result.dart';
import '../entities/face_enrollment_data.dart';

abstract class FaceEnrollmentRepository {
  Future<Result<FaceEnrollmentResult>> enrollFace({
    required String utilisateurUuid,
    required List<String> imagePaths,
  });
}
