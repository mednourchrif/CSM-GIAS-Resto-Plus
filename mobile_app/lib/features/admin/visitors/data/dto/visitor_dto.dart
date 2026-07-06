import '../../domain/entities/visitor.dart';

class VisitorDto {
  final int id;
  final String uuid;
  final String nom;
  final String prenom;
  final String? email;
  final String? societe;
  final String statut;
  final String? langue;
  final DateTime dateVisite;
  final DateTime? dateSuppression;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const VisitorDto({
    required this.id,
    required this.uuid,
    required this.nom,
    required this.prenom,
    this.email,
    this.societe,
    required this.statut,
    this.langue,
    required this.dateVisite,
    this.dateSuppression,
    this.createdAt,
    this.updatedAt,
  });

  factory VisitorDto.fromJson(Map<String, dynamic> json) {
    return VisitorDto(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      email: json['email'] as String?,
      societe: json['societe'] as String?,
      statut: json['statut'] as String? ?? 'ACTIF',
      langue: json['langue'] as String?,
      dateVisite: DateTime.parse(json['date_visite'] as String),
      dateSuppression: json['date_suppression'] != null
          ? DateTime.tryParse(json['date_suppression'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  Visitor toDomain() => Visitor(
        id: id,
        uuid: uuid,
        nom: nom,
        prenom: prenom,
        email: email,
        societe: societe,
        statut: statut,
        langue: langue,
        dateVisite: dateVisite,
        dateSuppression: dateSuppression,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
