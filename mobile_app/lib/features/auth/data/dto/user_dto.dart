import '../../domain/entities/user.dart';

class UserDto {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String role;

  const UserDto({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.role,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as int,
      nom: json['nom'] as String,
      prenom: json['prenom'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
    );
  }

  User toDomain() => User(
        id: id,
        nom: nom,
        prenom: prenom,
        email: email,
        role: role,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'role': role,
      };
}
