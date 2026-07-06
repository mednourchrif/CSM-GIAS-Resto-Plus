import '../../domain/entities/qr_code.dart';

class QrGenerateResponseDto {
  final int id;
  final String uuid;
  final String qrHash;
  final String proprietaireUuid;
  final String typeProprietaire;
  final String statut;
  final DateTime dateExpiration;
  final String qrToken;
  final String qrBase64;
  final String? creeParUuid;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const QrGenerateResponseDto({
    required this.id,
    required this.uuid,
    required this.qrHash,
    required this.proprietaireUuid,
    required this.typeProprietaire,
    required this.statut,
    required this.dateExpiration,
    required this.qrToken,
    required this.qrBase64,
    this.creeParUuid,
    this.createdAt,
    this.updatedAt,
  });

  factory QrGenerateResponseDto.fromJson(Map<String, dynamic> json) {
    return QrGenerateResponseDto(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      qrHash: json['qr_hash'] as String,
      proprietaireUuid: json['proprietaire_uuid'] as String,
      typeProprietaire: json['type_proprietaire'] as String,
      statut: json['statut'] as String? ?? 'ACTIF',
      dateExpiration: DateTime.parse(json['date_expiration'] as String),
      qrToken: json['qr_token'] as String,
      qrBase64: json['qr_base64'] as String,
      creeParUuid: json['cree_par_uuid'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  QrCode toDomain() => QrCode(
        id: id,
        uuid: uuid,
        qrHash: qrHash,
        proprietaireUuid: proprietaireUuid,
        typeProprietaire: typeProprietaire,
        statut: statut,
        dateExpiration: dateExpiration,
        creeParUuid: creeParUuid,
        nombreValidations: 0,
        qrBase64: qrBase64,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
