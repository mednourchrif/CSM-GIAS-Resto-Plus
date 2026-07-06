class CreateEmployeeRequestDto {
  final String nom;
  final String prenom;
  final String matricule;
  final String? statut;

  const CreateEmployeeRequestDto({
    required this.nom,
    required this.prenom,
    required this.matricule,
    this.statut,
  });

  Map<String, dynamic> toJson() => {
        'nom': nom,
        'prenom': prenom,
        'matricule': matricule,
        if (statut != null) 'statut': statut,
      };
}
