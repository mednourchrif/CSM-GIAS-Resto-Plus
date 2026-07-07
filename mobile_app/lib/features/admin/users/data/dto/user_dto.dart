import '../../domain/entities/user.dart';

class AdminUserDto {
  final int id;
  final String uuid;
  final String nom;
  final String prenom;
  final String? email;
  final String type;
  final String statut;
  final String? roleName;
  final DateTime? derniereConnexion;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdById;
  final String? updatedById;

  const AdminUserDto({
    required this.id,
    required this.uuid,
    required this.nom,
    required this.prenom,
    this.email,
    required this.type,
    required this.statut,
    this.roleName,
    this.derniereConnexion,
    required this.createdAt,
    required this.updatedAt,
    this.createdById,
    this.updatedById,
  });

  factory AdminUserDto.fromJson(Map<String, dynamic> json) {
    return AdminUserDto(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      email: json['email'] as String?,
      type: json['type'] as String? ?? 'ADMINISTRATEUR',
      statut: json['statut'] as String? ?? 'ACTIF',
      roleName: json['role_name'] as String?,
      derniereConnexion: json['derniere_connexion'] != null
          ? DateTime.tryParse(json['derniere_connexion'] as String)
          : null,
      createdAt: DateTime.tryParse(json['created_at'] as String) ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now(),
      createdById: json['created_by_id'] as String?,
      updatedById: json['updated_by_id'] as String?,
    );
  }

  AdminUser toDomain() => AdminUser(
        id: id,
        uuid: uuid,
        nom: nom,
        prenom: prenom,
        email: email,
        type: type,
        statut: statut,
        roleName: roleName,
        derniereConnexion: derniereConnexion,
        createdAt: createdAt,
        updatedAt: updatedAt,
        createdById: createdById,
        updatedById: updatedById,
      );
}
