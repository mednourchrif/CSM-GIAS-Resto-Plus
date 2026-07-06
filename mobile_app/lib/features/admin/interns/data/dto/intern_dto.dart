import '../../domain/entities/intern.dart';

class InternDto {
  final int id;
  final String uuid;
  final String nom;
  final String prenom;
  final String? email;
  final String matricule;
  final String statut;
  final String? langue;
  final DateTime dateDebutStage;
  final DateTime dateFinStage;
  final DateTime? dateSuppression;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const InternDto({
    required this.id,
    required this.uuid,
    required this.nom,
    required this.prenom,
    this.email,
    required this.matricule,
    required this.statut,
    this.langue,
    required this.dateDebutStage,
    required this.dateFinStage,
    this.dateSuppression,
    this.createdAt,
    this.updatedAt,
  });

  factory InternDto.fromJson(Map<String, dynamic> json) {
    return InternDto(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      email: json['email'] as String?,
      matricule: json['matricule'] as String,
      statut: json['statut'] as String? ?? 'ACTIF',
      langue: json['langue'] as String?,
      dateDebutStage: DateTime.parse(json['date_debut_stage'] as String),
      dateFinStage: DateTime.parse(json['date_fin_stage'] as String),
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

  Intern toDomain() => Intern(
        id: id,
        uuid: uuid,
        nom: nom,
        prenom: prenom,
        matricule: matricule,
        statut: statut,
        langue: langue,
        dateDebutStage: dateDebutStage,
        dateFinStage: dateFinStage,
        dateSuppression: dateSuppression,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
