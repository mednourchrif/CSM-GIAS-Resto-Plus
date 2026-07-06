import '../../../../shared/models/result.dart';
import '../entities/face_recognition_result.dart';

abstract class FaceRecognitionRepository {
  Future<Result<FaceRecognitionResult>> identify({
    required String imageBase64,
    String? categorieUuid,
  });
}
