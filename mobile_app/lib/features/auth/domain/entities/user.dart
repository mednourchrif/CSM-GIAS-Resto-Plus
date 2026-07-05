class User {
  final int id;
  final String nom;
  final String prenom;
  final String email;
  final String role;

  const User({
    required this.id,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.role,
  });

  String get fullName => '$prenom $nom';
}
