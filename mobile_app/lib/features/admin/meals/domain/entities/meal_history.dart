enum TypeIdentification { qr, face, unknown }

enum UserType { employe, stagiaire, visiteur, unknown }

class MealHistory {
  final String uuid;
  final String utilisateurUuid;
  final String? nom;
  final String? prenom;
  final String? email;
  final TypeIdentification typeIdentification;
  final String categorieUuid;
  final String? categorieNom;
  final DateTime dateRepas;
  final String heureRepas;

  const MealHistory({
    required this.uuid,
    required this.utilisateurUuid,
    this.nom,
    this.prenom,
    this.email,
    required this.typeIdentification,
    required this.categorieUuid,
    this.categorieNom,
    required this.dateRepas,
    required this.heureRepas,
  });

  String get displayName => '${prenom ?? ""} ${nom ?? ""}'.trim();
  bool get isFace => typeIdentification == TypeIdentification.face;
}

class MealStats {
  final int totalMeals;
  final int totalEmployees;
  final int totalInterns;
  final int totalVisitors;
  final int faceRegistrations;
  final int qrRegistrations;

  const MealStats({
    required this.totalMeals,
    required this.totalEmployees,
    required this.totalInterns,
    required this.totalVisitors,
    required this.faceRegistrations,
    required this.qrRegistrations,
  });
}
