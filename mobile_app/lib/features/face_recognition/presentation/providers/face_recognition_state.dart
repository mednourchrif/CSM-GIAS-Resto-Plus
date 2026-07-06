import '../../domain/entities/face_recognition_result.dart';

class FaceRecognitionState {
  final bool isLoading;
  final FaceRecognitionResult? result;
  final String? error;

  const FaceRecognitionState({
    this.isLoading = false,
    this.result,
    this.error,
  });

  FaceRecognitionState copyWith({
    bool? isLoading,
    FaceRecognitionResult? result,
    String? error,
    bool clearError = false,
  }) {
    return FaceRecognitionState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
