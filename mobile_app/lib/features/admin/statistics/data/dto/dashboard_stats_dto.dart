import '../../domain/entities/dashboard_stats.dart';

class MealCountByDateDto {
  final String date;
  final int count;
  const MealCountByDateDto({required this.date, required this.count});
  factory MealCountByDateDto.fromJson(Map<String, dynamic> json) =>
      MealCountByDateDto(
        date: json['date'] as String,
        count: json['count'] as int? ?? 0,
      );
}

class MealDistributionItemDto {
  final String name;
  final int count;
  const MealDistributionItemDto({required this.name, required this.count});
  factory MealDistributionItemDto.fromJson(Map<String, dynamic> json) =>
      MealDistributionItemDto(
        name: json['name'] as String,
        count: json['count'] as int? ?? 0,
      );
}

class UserTypeDistributionItemDto {
  final String type;
  final int count;
  const UserTypeDistributionItemDto({required this.type, required this.count});
  factory UserTypeDistributionItemDto.fromJson(Map<String, dynamic> json) =>
      UserTypeDistributionItemDto(
        type: json['type'] as String,
        count: json['count'] as int? ?? 0,
      );
}

class RegistrationMethodItemDto {
  final String method;
  final int count;
  const RegistrationMethodItemDto({required this.method, required this.count});
  factory RegistrationMethodItemDto.fromJson(Map<String, dynamic> json) =>
      RegistrationMethodItemDto(
        method: json['method'] as String,
        count: json['count'] as int? ?? 0,
      );
}

class PeakHourItemDto {
  final int hour;
  final int count;
  const PeakHourItemDto({required this.hour, required this.count});
  factory PeakHourItemDto.fromJson(Map<String, dynamic> json) =>
      PeakHourItemDto(
        hour: json['hour'] as int? ?? 0,
        count: json['count'] as int? ?? 0,
      );
}

class RecentRegistrationItemDto {
  final String uuid;
  final String utilisateurUuid;
  final String? nom;
  final String? prenom;
  final String typeIdentification;
  final String dateRepas;
  final String heureRepas;
  final String? categorieNom;

  const RecentRegistrationItemDto({
    required this.uuid,
    required this.utilisateurUuid,
    this.nom,
    this.prenom,
    required this.typeIdentification,
    required this.dateRepas,
    required this.heureRepas,
    this.categorieNom,
  });

  factory RecentRegistrationItemDto.fromJson(Map<String, dynamic> json) =>
      RecentRegistrationItemDto(
        uuid: json['uuid'] as String,
        utilisateurUuid: json['utilisateur_uuid'] as String,
        nom: json['nom'] as String?,
        prenom: json['prenom'] as String?,
        typeIdentification: json['type_identification'] as String? ?? 'QR',
        dateRepas: json['date_repas'] as String,
        heureRepas: json['heure_repas'] as String,
        categorieNom: json['categorie_nom'] as String?,
      );
}

class DashboardStatsDto {
  final Map<String, dynamic> overview;
  final List<MealCountByDateDto> mealsPerDay;
  final List<MealDistributionItemDto> mealDistribution;
  final List<UserTypeDistributionItemDto> userTypeDistribution;
  final List<RegistrationMethodItemDto> registrationMethods;
  final List<PeakHourItemDto> peakHours;
  final List<RecentRegistrationItemDto> recentRegistrations;

  const DashboardStatsDto({
    required this.overview,
    required this.mealsPerDay,
    required this.mealDistribution,
    required this.userTypeDistribution,
    required this.registrationMethods,
    required this.peakHours,
    required this.recentRegistrations,
  });

  factory DashboardStatsDto.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    return DashboardStatsDto(
      overview: data['overview'] as Map<String, dynamic>? ?? {},
      mealsPerDay:
          (data['meals_per_day'] as List<dynamic>?)
              ?.map(
                (e) => MealCountByDateDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      mealDistribution:
          (data['meal_distribution'] as List<dynamic>?)
              ?.map(
                (e) =>
                    MealDistributionItemDto.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
      userTypeDistribution:
          (data['user_type_distribution'] as List<dynamic>?)
              ?.map(
                (e) => UserTypeDistributionItemDto.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      registrationMethods:
          (data['registration_methods'] as List<dynamic>?)
              ?.map(
                (e) => RegistrationMethodItemDto.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
      peakHours:
          (data['peak_hours'] as List<dynamic>?)
              ?.map((e) => PeakHourItemDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recentRegistrations:
          (data['recent_registrations'] as List<dynamic>?)
              ?.map(
                (e) => RecentRegistrationItemDto.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
    );
  }

  DashboardStats toEntity() => DashboardStats(
    overview: overview,
    mealsPerDay: mealsPerDay
        .map((e) => MealCountByDate(date: e.date, count: e.count))
        .toList(),
    mealDistribution: mealDistribution
        .map((e) => MealDistributionItem(name: e.name, count: e.count))
        .toList(),
    userTypeDistribution: userTypeDistribution
        .map((e) => UserTypeDistributionItem(type: e.type, count: e.count))
        .toList(),
    registrationMethods: registrationMethods
        .map((e) => RegistrationMethodItem(method: e.method, count: e.count))
        .toList(),
    peakHours: peakHours
        .map((e) => PeakHourItem(hour: e.hour, count: e.count))
        .toList(),
    recentRegistrations: recentRegistrations
        .map(
          (e) => RecentRegistrationItem(
            uuid: e.uuid,
            utilisateurUuid: e.utilisateurUuid,
            nom: e.nom,
            prenom: e.prenom,
            typeIdentification: e.typeIdentification,
            dateRepas: e.dateRepas,
            heureRepas: e.heureRepas,
            categorieNom: e.categorieNom,
          ),
        )
        .toList(),
  );
}
