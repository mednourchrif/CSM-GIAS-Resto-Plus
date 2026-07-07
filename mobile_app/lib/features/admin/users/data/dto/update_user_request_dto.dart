class UpdateAdminUserRequestDto {
  final String? nom;
  final String? prenom;
  final String? email;
  final String? statut;
  final int? roleId;

  const UpdateAdminUserRequestDto({
    this.nom,
    this.prenom,
    this.email,
    this.statut,
    this.roleId,
  });

  Map<String, dynamic> toJson() => {
        if (nom != null) 'nom': nom,
        if (prenom != null) 'prenom': prenom,
        if (email != null) 'email': email,
        if (statut != null) 'statut': statut,
        if (roleId != null) 'role_id': roleId,
      };
}
