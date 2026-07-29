class FaceRecognitionResult {
  final String statut;
  final double? confidence;
  final String? type;
  final String? message;
  final String? identificationToken;
  final DateTime? identificationExpiresAt;

  const FaceRecognitionResult({
    required this.statut,
    this.confidence,
    this.type,
    this.message,
    this.identificationToken,
    this.identificationExpiresAt,
  });

  bool get isMatch => statut == 'MATCH';
}
