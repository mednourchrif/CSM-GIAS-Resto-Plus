import '../../../../shared/models/result.dart';
import '../entities/face_recognition_result.dart';
import '../repositories/face_recognition_repository.dart';

class IdentifyFaceUseCase {
  final FaceRecognitionRepository _repository;

  IdentifyFaceUseCase(this._repository);

  Future<Result<FaceRecognitionResult>> call({
    required String imageBase64,
    String? categorieUuid,
  }) {
    return _repository.identify(
      imageBase64: imageBase64,
      categorieUuid: categorieUuid,
    );
  }
}
