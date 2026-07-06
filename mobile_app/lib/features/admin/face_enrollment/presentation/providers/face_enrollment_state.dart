import '../../domain/entities/face_enrollment_data.dart';

enum EnrollmentStep { camera, preview, uploading, done, error }

class FaceEnrollmentState {
  final EnrollmentStep step;
  final List<CapturedImage> capturedImages;
  final bool isUploading;
  final double uploadProgress;
  final String? errorMessage;
  final FaceEnrollmentResult? result;

  const FaceEnrollmentState({
    this.step = EnrollmentStep.camera,
    this.capturedImages = const [],
    this.isUploading = false,
    this.uploadProgress = 0,
    this.errorMessage,
    this.result,
  });

  FaceEnrollmentState copyWith({
    EnrollmentStep? step,
    List<CapturedImage>? capturedImages,
    bool? isUploading,
    double? uploadProgress,
    String? errorMessage,
    FaceEnrollmentResult? result,
    bool clearError = false,
  }) {
    return FaceEnrollmentState(
      step: step ?? this.step,
      capturedImages: capturedImages ?? this.capturedImages,
      isUploading: isUploading ?? this.isUploading,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      result: result ?? this.result,
    );
  }
}
