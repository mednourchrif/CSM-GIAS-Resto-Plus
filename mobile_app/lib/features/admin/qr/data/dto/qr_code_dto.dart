import '../../domain/entities/qr_code.dart';

class QrCodeDto {
  final int id;
  final String uuid;
  final String qrHash;
  final String proprietaireUuid;
  final String typeProprietaire;
  final String statut;
  final DateTime dateExpiration;
  final String? creeParUuid;
  final DateTime? dateRevocation;
  final String? revoqueParUuid;
  final String? motifRevocation;
  final DateTime? derniereValidation;
  final int nombreValidations;
  final String? metadataJson;
  final String? qrBase64;
  final String? proprietaireNom;
  final String? proprietairePrenom;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const QrCodeDto({
    required this.id,
    required this.uuid,
    required this.qrHash,
    required this.proprietaireUuid,
    required this.typeProprietaire,
    required this.statut,
    required this.dateExpiration,
    this.creeParUuid,
    this.dateRevocation,
    this.revoqueParUuid,
    this.motifRevocation,
    this.derniereValidation,
    this.nombreValidations = 0,
    this.metadataJson,
    this.qrBase64,
    this.proprietaireNom,
    this.proprietairePrenom,
    this.createdAt,
    this.updatedAt,
  });

  factory QrCodeDto.fromJson(Map<String, dynamic> json) {
    return QrCodeDto(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      qrHash: json['qr_hash'] as String,
      proprietaireUuid: json['proprietaire_uuid'] as String,
      typeProprietaire: json['type_proprietaire'] as String,
      statut: json['statut'] as String? ?? 'ACTIF',
      dateExpiration: DateTime.parse(json['date_expiration'] as String),
      creeParUuid: json['cree_par_uuid'] as String?,
      dateRevocation: json['date_revocation'] != null
          ? DateTime.tryParse(json['date_revocation'] as String)
          : null,
      revoqueParUuid: json['revoque_par_uuid'] as String?,
      motifRevocation: json['motif_revocation'] as String?,
      derniereValidation: json['derniere_validation'] != null
          ? DateTime.tryParse(json['derniere_validation'] as String)
          : null,
      nombreValidations: json['nombre_validations'] as int? ?? 0,
      metadataJson: json['metadata_json'] as String?,
      qrBase64: json['qr_base64'] as String?,
      proprietaireNom: json['proprietaire_nom'] as String?,
      proprietairePrenom: json['proprietaire_prenom'] as String?,
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
        dateRevocation: dateRevocation,
        revoqueParUuid: revoqueParUuid,
        motifRevocation: motifRevocation,
        derniereValidation: derniereValidation,
        nombreValidations: nombreValidations,
        metadataJson: metadataJson,
        qrBase64: qrBase64,
        proprietaireNom: proprietaireNom,
        proprietairePrenom: proprietairePrenom,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
