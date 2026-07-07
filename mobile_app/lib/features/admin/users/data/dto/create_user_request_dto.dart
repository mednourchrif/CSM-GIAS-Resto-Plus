class CreateAdminUserRequestDto {
  final String nom;
  final String prenom;
  final String email;
  final String motDePasse;
  final String type;
  final int? roleId;

  const CreateAdminUserRequestDto({
    required this.nom,
    required this.prenom,
    required this.email,
    required this.motDePasse,
    required this.type,
    this.roleId,
  });

  Map<String, dynamic> toJson() => {
        'nom': nom,
        'prenom': prenom,
        'email': email,
        'mot_de_passe': motDePasse,
        'type': type,
        if (roleId != null) 'role_id': roleId,
      };
}
