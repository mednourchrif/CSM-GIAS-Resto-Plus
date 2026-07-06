class CapturedImage {
  final String filePath;
  final DateTime capturedAt;

  const CapturedImage({
    required this.filePath,
    required this.capturedAt,
  });
}

class FaceEnrollmentResult {
  final bool success;
  final String? errorMessage;
  final int imagesUploaded;

  const FaceEnrollmentResult({
    required this.success,
    this.errorMessage,
    this.imagesUploaded = 0,
  });
}
