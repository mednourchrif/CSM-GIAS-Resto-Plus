class MealHistoryDto {
  final String uuid;
  final String utilisateurUuid;
  final String? nom;
  final String? prenom;
  final String? email;
  final String typeIdentification;
  final String categorieUuid;
  final String? categorieNom;
  final String dateRepas;
  final String heureRepas;

  const MealHistoryDto({
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

  factory MealHistoryDto.fromJson(Map<String, dynamic> json) {
    return MealHistoryDto(
      uuid: json['uuid'] as String,
      utilisateurUuid: json['utilisateur_uuid'] as String,
      nom: json['nom'] as String?,
      prenom: json['prenom'] as String?,
      email: json['email'] as String?,
      typeIdentification: json['type_identification'] as String? ?? 'QR',
      categorieUuid: json['categorie_uuid'] as String,
      categorieNom: json['categorie_nom'] as String?,
      dateRepas: json['date_repas'] as String,
      heureRepas: json['heure_repas'] as String,
    );
  }
}

class MealStatsDto {
  final int totalMeals;
  final int totalEmployees;
  final int totalInterns;
  final int totalVisitors;
  final int faceRegistrations;
  final int qrRegistrations;

  const MealStatsDto({
    required this.totalMeals,
    required this.totalEmployees,
    required this.totalInterns,
    required this.totalVisitors,
    required this.faceRegistrations,
    required this.qrRegistrations,
  });

  factory MealStatsDto.fromJson(Map<String, dynamic> json) {
    return MealStatsDto(
      totalMeals: json['total_meals'] as int? ?? 0,
      totalEmployees: json['total_employees'] as int? ?? 0,
      totalInterns: json['total_interns'] as int? ?? 0,
      totalVisitors: json['total_visitors'] as int? ?? 0,
      faceRegistrations: json['face_registrations'] as int? ?? 0,
      qrRegistrations: json['qr_registrations'] as int? ?? 0,
    );
  }
}

class PaginatedMealHistoryDto {
  final List<MealHistoryDto> data;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  const PaginatedMealHistoryDto({
    required this.data,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory PaginatedMealHistoryDto.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] as List<dynamic>? ?? [];
    return PaginatedMealHistoryDto(
      data: rawData
          .map((e) => MealHistoryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 20,
      totalPages: json['total_pages'] as int? ?? 1,
    );
  }
}
