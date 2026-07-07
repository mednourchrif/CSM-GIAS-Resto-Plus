import '../../domain/entities/dashboard_stats.dart';

class MealCountByDateDto {
  final String date;
  final int count;
  const MealCountByDateDto({required this.date, required this.count});
  factory MealCountByDateDto.fromJson(Map<String, dynamic> json) =>
      MealCountByDateDto(date: json['date'] as String, count: json['count'] as int? ?? 0);
}

class MealDistributionItemDto {
  final String name;
  final int count;
  const MealDistributionItemDto({required this.name, required this.count});
  factory MealDistributionItemDto.fromJson(Map<String, dynamic> json) =>
      MealDistributionItemDto(name: json['name'] as String, count: json['count'] as int? ?? 0);
}

class UserTypeDistributionItemDto {
  final String type;
  final int count;
  const UserTypeDistributionItemDto({required this.type, required this.count});
  factory UserTypeDistributionItemDto.fromJson(Map<String, dynamic> json) =>
      UserTypeDistributionItemDto(type: json['type'] as String, count: json['count'] as int? ?? 0);
}

class RegistrationMethodItemDto {
  final String method;
  final int count;
  const RegistrationMethodItemDto({required this.method, required this.count});
  factory RegistrationMethodItemDto.fromJson(Map<String, dynamic> json) =>
      RegistrationMethodItemDto(method: json['method'] as String, count: json['count'] as int? ?? 0);
}

class PeakHourItemDto {
  final int hour;
  final int count;
  const PeakHourItemDto({required this.hour, required this.count});
  factory PeakHourItemDto.fromJson(Map<String, dynamic> json) =>
      PeakHourItemDto(hour: json['hour'] as int? ?? 0, count: json['count'] as int? ?? 0);
}

class RecentRegistrationItemDto {
  final String uuid;
  final String utilisateur_uuid;
  final String? nom;
  final String? prenom;
  final String type_identification;
  final String date_repas;
  final String heure_repas;
  final String? categorie_nom;

  const RecentRegistrationItemDto({
    required this.uuid,
    required this.utilisateur_uuid,
    this.nom,
    this.prenom,
    required this.type_identification,
    required this.date_repas,
    required this.heure_repas,
    this.categorie_nom,
  });

  factory RecentRegistrationItemDto.fromJson(Map<String, dynamic> json) =>
      RecentRegistrationItemDto(
        uuid: json['uuid'] as String,
        utilisateur_uuid: json['utilisateur_uuid'] as String,
        nom: json['nom'] as String?,
        prenom: json['prenom'] as String?,
        type_identification: json['type_identification'] as String? ?? 'QR',
        date_repas: json['date_repas'] as String,
        heure_repas: json['heure_repas'] as String,
        categorie_nom: json['categorie_nom'] as String?,
      );
}

class DashboardStatsDto {
  final Map<String, dynamic> overview;
  final List<MealCountByDateDto> meals_per_day;
  final List<MealDistributionItemDto> meal_distribution;
  final List<UserTypeDistributionItemDto> user_type_distribution;
  final List<RegistrationMethodItemDto> registration_methods;
  final List<PeakHourItemDto> peak_hours;
  final List<RecentRegistrationItemDto> recent_registrations;

  const DashboardStatsDto({
    required this.overview,
    required this.meals_per_day,
    required this.meal_distribution,
    required this.user_type_distribution,
    required this.registration_methods,
    required this.peak_hours,
    required this.recent_registrations,
  });

  factory DashboardStatsDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return DashboardStatsDto(
      overview: data['overview'] as Map<String, dynamic>? ?? {},
      meals_per_day: (data['meals_per_day'] as List<dynamic>?)
              ?.map((e) => MealCountByDateDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      meal_distribution: (data['meal_distribution'] as List<dynamic>?)
              ?.map((e) => MealDistributionItemDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      user_type_distribution: (data['user_type_distribution'] as List<dynamic>?)
              ?.map((e) => UserTypeDistributionItemDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      registration_methods: (data['registration_methods'] as List<dynamic>?)
              ?.map((e) => RegistrationMethodItemDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      peak_hours: (data['peak_hours'] as List<dynamic>?)
              ?.map((e) => PeakHourItemDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recent_registrations: (data['recent_registrations'] as List<dynamic>?)
              ?.map((e) => RecentRegistrationItemDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  DashboardStats toEntity() => DashboardStats(
        overview: overview,
        mealsPerDay: meals_per_day
            .map((e) => MealCountByDate(date: e.date, count: e.count))
            .toList(),
        mealDistribution: meal_distribution
            .map((e) => MealDistributionItem(name: e.name, count: e.count))
            .toList(),
        userTypeDistribution: user_type_distribution
            .map((e) => UserTypeDistributionItem(type: e.type, count: e.count))
            .toList(),
        registrationMethods: registration_methods
            .map((e) => RegistrationMethodItem(method: e.method, count: e.count))
            .toList(),
        peakHours: peak_hours
            .map((e) => PeakHourItem(hour: e.hour, count: e.count))
            .toList(),
        recentRegistrations: recent_registrations
            .map((e) => RecentRegistrationItem(
                  uuid: e.uuid,
                  utilisateurUuid: e.utilisateur_uuid,
                  nom: e.nom,
                  prenom: e.prenom,
                  typeIdentification: e.type_identification,
                  dateRepas: e.date_repas,
                  heureRepas: e.heure_repas,
                  categorieNom: e.categorie_nom,
                ))
            .toList(),
      );
}
