class UpdateEmployeeRequestDto {
  final String? nom;
  final String? prenom;
  final String? matricule;
  final String? statut;

  const UpdateEmployeeRequestDto({
    this.nom,
    this.prenom,
    this.matricule,
    this.statut,
  });

  Map<String, dynamic> toJson() => {
        if (nom != null) 'nom': nom,
        if (prenom != null) 'prenom': prenom,
        if (matricule != null) 'matricule': matricule,
        if (statut != null) 'statut': statut,
      };
}
