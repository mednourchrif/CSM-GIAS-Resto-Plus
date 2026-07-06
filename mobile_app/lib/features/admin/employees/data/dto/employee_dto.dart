import '../../domain/entities/employee.dart';

class EmployeeDto {
  final int id;
  final String uuid;
  final String nom;
  final String prenom;
  final String? email;
  final String matricule;
  final String? photoPath;
  final String statut;
  final String statutEnrolement;
  final DateTime? dateEnrolement;
  final DateTime? dateSuppression;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EmployeeDto({
    required this.id,
    required this.uuid,
    required this.nom,
    required this.prenom,
    this.email,
    required this.matricule,
    this.photoPath,
    required this.statut,
    required this.statutEnrolement,
    this.dateEnrolement,
    this.dateSuppression,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EmployeeDto.fromJson(Map<String, dynamic> json) {
    return EmployeeDto(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      email: json['email'] as String?,
      matricule: json['matricule'] as String,
      photoPath: json['photo_path'] as String?,
      statut: json['statut'] as String? ?? 'ACTIF',
      statutEnrolement: json['statut_enrolement'] as String? ?? 'NON_ENROLE',
      dateEnrolement: json['date_enrolement'] != null
          ? DateTime.tryParse(json['date_enrolement'] as String)
          : null,
      dateSuppression: json['date_suppression'] != null
          ? DateTime.tryParse(json['date_suppression'] as String)
          : null,
      createdAt: DateTime.tryParse(json['created_at'] as String) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now(),
    );
  }

  Employee toDomain() => Employee(
        id: id,
        uuid: uuid,
        nom: nom,
        prenom: prenom,
        matricule: matricule,
        photoPath: photoPath,
        statut: statut,
        statutEnrolement: statutEnrolement,
        dateEnrolement: dateEnrolement,
        dateSuppression: dateSuppression,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
