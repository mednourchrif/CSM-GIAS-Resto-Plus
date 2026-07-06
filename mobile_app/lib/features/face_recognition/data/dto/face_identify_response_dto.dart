import '../../domain/entities/face_recognition_result.dart';

class FaceIdentifyResponseDto {
  final String statut;
  final double? confidence;
  final String? utilisateurUuid;
  final String? nom;
  final String? prenom;
  final String? type;
  final String? message;

  const FaceIdentifyResponseDto({
    required this.statut,
    this.confidence,
    this.utilisateurUuid,
    this.nom,
    this.prenom,
    this.type,
    this.message,
  });

  factory FaceIdentifyResponseDto.fromJson(Map<String, dynamic> json) {
    return FaceIdentifyResponseDto(
      statut: json['statut'] as String? ?? 'NO_MATCH',
      confidence: (json['confidence'] as num?)?.toDouble(),
      utilisateurUuid: json['utilisateur_uuid'] as String?,
      nom: json['nom'] as String?,
      prenom: json['prenom'] as String?,
      type: json['type'] as String?,
      message: json['message'] as String?,
    );
  }

  FaceRecognitionResult toDomain() => FaceRecognitionResult(
        statut: statut,
        confidence: confidence,
        utilisateurUuid: utilisateurUuid,
        nom: nom,
        prenom: prenom,
        type: type,
        message: message,
      );
}
