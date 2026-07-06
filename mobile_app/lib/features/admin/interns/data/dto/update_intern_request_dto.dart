class UpdateInternRequestDto {
  final String? nom;
  final String? prenom;
  final String? matricule;
  final String? dateDebutStage;
  final String? dateFinStage;
  final String? statut;

  const UpdateInternRequestDto({
    this.nom,
    this.prenom,
    this.matricule,
    this.dateDebutStage,
    this.dateFinStage,
    this.statut,
  });

  Map<String, dynamic> toJson() => {
        if (nom != null) 'nom': nom,
        if (prenom != null) 'prenom': prenom,
        if (matricule != null) 'matricule': matricule,
        if (dateDebutStage != null) 'date_debut_stage': dateDebutStage,
        if (dateFinStage != null) 'date_fin_stage': dateFinStage,
        if (statut != null) 'statut': statut,
      };
}
