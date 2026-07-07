class MealHistoryDto {
  final String uuid;
  final String utilisateur_uuid;
  final String? nom;
  final String? prenom;
  final String? email;
  final String type_identification;
  final String categorie_uuid;
  final String? categorie_nom;
  final String date_repas;
  final String heure_repas;

  const MealHistoryDto({
    required this.uuid,
    required this.utilisateur_uuid,
    this.nom,
    this.prenom,
    this.email,
    required this.type_identification,
    required this.categorie_uuid,
    this.categorie_nom,
    required this.date_repas,
    required this.heure_repas,
  });

  factory MealHistoryDto.fromJson(Map<String, dynamic> json) {
    return MealHistoryDto(
      uuid: json['uuid'] as String,
      utilisateur_uuid: json['utilisateur_uuid'] as String,
      nom: json['nom'] as String?,
      prenom: json['prenom'] as String?,
      email: json['email'] as String?,
      type_identification: json['type_identification'] as String? ?? 'QR',
      categorie_uuid: json['categorie_uuid'] as String,
      categorie_nom: json['categorie_nom'] as String?,
      date_repas: json['date_repas'] as String,
      heure_repas: json['heure_repas'] as String,
    );
  }
}

class MealStatsDto {
  final int total_meals;
  final int total_employees;
  final int total_interns;
  final int total_visitors;
  final int face_registrations;
  final int qr_registrations;

  const MealStatsDto({
    required this.total_meals,
    required this.total_employees,
    required this.total_interns,
    required this.total_visitors,
    required this.face_registrations,
    required this.qr_registrations,
  });

  factory MealStatsDto.fromJson(Map<String, dynamic> json) {
    return MealStatsDto(
      total_meals: json['total_meals'] as int? ?? 0,
      total_employees: json['total_employees'] as int? ?? 0,
      total_interns: json['total_interns'] as int? ?? 0,
      total_visitors: json['total_visitors'] as int? ?? 0,
      face_registrations: json['face_registrations'] as int? ?? 0,
      qr_registrations: json['qr_registrations'] as int? ?? 0,
    );
  }
}

class PaginatedMealHistoryDto {
  final List<MealHistoryDto> data;
  final int total;
  final int page;
  final int page_size;
  final int total_pages;

  const PaginatedMealHistoryDto({
    required this.data,
    required this.total,
    required this.page,
    required this.page_size,
    required this.total_pages,
  });

  factory PaginatedMealHistoryDto.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] as List<dynamic>? ?? [];
    return PaginatedMealHistoryDto(
      data: rawData
          .map((e) => MealHistoryDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      page_size: json['page_size'] as int? ?? 20,
      total_pages: json['total_pages'] as int? ?? 1,
    );
  }
}
