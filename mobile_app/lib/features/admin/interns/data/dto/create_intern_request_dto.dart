class CreateInternRequestDto {
  final String nom;
  final String prenom;
  final String matricule;
  final String dateDebutStage;
  final String dateFinStage;
  final String? statut;

  const CreateInternRequestDto({
    required this.nom,
    required this.prenom,
    required this.matricule,
    required this.dateDebutStage,
    required this.dateFinStage,
    this.statut,
  });

  Map<String, dynamic> toJson() => {
        'nom': nom,
        'prenom': prenom,
        'matricule': matricule,
        'date_debut_stage': dateDebutStage,
        'date_fin_stage': dateFinStage,
        if (statut != null) 'statut': statut,
      };
}
