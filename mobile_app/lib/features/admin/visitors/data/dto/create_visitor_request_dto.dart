class CreateVisitorRequestDto {
  final String nom;
  final String prenom;
  final String? email;
  final String? societe;
  final String dateVisite;
  final String? statut;

  const CreateVisitorRequestDto({
    required this.nom,
    required this.prenom,
    this.email,
    this.societe,
    required this.dateVisite,
    this.statut,
  });

  Map<String, dynamic> toJson() => {
        'nom': nom,
        'prenom': prenom,
        if (email != null) 'email': email,
        if (societe != null) 'societe': societe,
        'date_visite': dateVisite,
        if (statut != null) 'statut': statut,
      };
}
