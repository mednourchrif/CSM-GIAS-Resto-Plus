class FaceRecognitionResult {
  final String statut;
  final double? confidence;
  final String? utilisateurUuid;
  final String? nom;
  final String? prenom;
  final String? type;
  final String? message;

  const FaceRecognitionResult({
    required this.statut,
    this.confidence,
    this.utilisateurUuid,
    this.nom,
    this.prenom,
    this.type,
    this.message,
  });

  bool get isMatch => statut == 'MATCH';
}
