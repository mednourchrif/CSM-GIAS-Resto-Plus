class UpdateVisitorRequestDto {
  final String? nom;
  final String? prenom;
  final String? email;
  final String? societe;
  final String? dateVisite;
  final String? statut;

  const UpdateVisitorRequestDto({
    this.nom,
    this.prenom,
    this.email,
    this.societe,
    this.dateVisite,
    this.statut,
  });

  Map<String, dynamic> toJson() => {
        if (nom != null) 'nom': nom,
        if (prenom != null) 'prenom': prenom,
        if (email != null) 'email': email,
        if (societe != null) 'societe': societe,
        if (dateVisite != null) 'date_visite': dateVisite,
        if (statut != null) 'statut': statut,
      };
}
