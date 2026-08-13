class Receipt {
  final String uuid;
  final String number;
  final String mealUuid;
  final String userUuid;
  final String firstName;
  final String lastName;
  final String? employeeNumber;
  final String userType;
  final String categoryUuid;
  final String categoryName;
  final String identificationType;
  final DateTime mealDate;
  final DateTime servedAt;
  final int printCount;
  final DateTime? lastPrintedAt;
  final String? qrToken;

  const Receipt({
    required this.uuid,
    required this.number,
    required this.mealUuid,
    required this.userUuid,
    required this.firstName,
    required this.lastName,
    this.employeeNumber,
    required this.userType,
    required this.categoryUuid,
    required this.categoryName,
    required this.identificationType,
    required this.mealDate,
    required this.servedAt,
    this.printCount = 0,
    this.lastPrintedAt,
    this.qrToken,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory Receipt.fromJson(Map<String, dynamic> json) => Receipt(
    uuid: json['uuid'] as String,
    number: json['numero'] as String,
    mealUuid: json['repas_uuid'] as String,
    userUuid: json['utilisateur_uuid'] as String,
    firstName: json['prenom'] as String? ?? '',
    lastName: json['nom'] as String? ?? '',
    employeeNumber: json['matricule'] as String?,
    userType: json['type_utilisateur'] as String? ?? '',
    categoryUuid: json['categorie_uuid'] as String? ?? '',
    categoryName: json['categorie_nom'] as String? ?? '',
    identificationType: json['type_identification'] as String? ?? '',
    mealDate: DateTime.parse(json['date_repas'] as String),
    servedAt: DateTime.parse(json['heure_repas'] as String),
    printCount: json['nombre_impressions'] as int? ?? 0,
    lastPrintedAt: json['derniere_impression'] == null
        ? null
        : DateTime.parse(json['derniere_impression'] as String),
    qrToken: json['qr_token'] as String?,
  );
}
