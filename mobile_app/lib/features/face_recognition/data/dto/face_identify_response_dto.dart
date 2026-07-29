import '../../domain/entities/face_recognition_result.dart';
import '../../../../core/utils/api_datetime.dart';

class FaceIdentifyResponseDto {
  final String statut;
  final double? confidence;
  final String? type;
  final String? message;
  final String? identificationToken;
  final DateTime? identificationExpiresAt;

  const FaceIdentifyResponseDto({
    required this.statut,
    this.confidence,
    this.type,
    this.message,
    this.identificationToken,
    this.identificationExpiresAt,
  });

  factory FaceIdentifyResponseDto.fromJson(Map<String, dynamic> json) {
    return FaceIdentifyResponseDto(
      statut: json['statut'] as String? ?? 'NO_MATCH',
      confidence: (json['confidence'] as num?)?.toDouble(),
      type: json['type'] as String?,
      message: json['message'] as String?,
      identificationToken: json['identification_token'] as String?,
      identificationExpiresAt: tryParseApiUtcDateTime(
        json['identification_expires_at'],
      ),
    );
  }

  FaceRecognitionResult toDomain() => FaceRecognitionResult(
    statut: statut,
    confidence: confidence,
    type: type,
    message: message,
    identificationToken: identificationToken,
    identificationExpiresAt: identificationExpiresAt,
  );
}
