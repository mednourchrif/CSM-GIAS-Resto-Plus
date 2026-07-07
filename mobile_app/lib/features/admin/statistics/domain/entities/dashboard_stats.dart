class MealCountByDate {
  final String date;
  final int count;
  const MealCountByDate({required this.date, required this.count});
}

class MealDistributionItem {
  final String name;
  final int count;
  const MealDistributionItem({required this.name, required this.count});
}

class UserTypeDistributionItem {
  final String type;
  final int count;
  const UserTypeDistributionItem({required this.type, required this.count});
}

class RegistrationMethodItem {
  final String method;
  final int count;
  const RegistrationMethodItem({required this.method, required this.count});
}

class PeakHourItem {
  final int hour;
  final int count;
  const PeakHourItem({required this.hour, required this.count});
}

class RecentRegistrationItem {
  final String uuid;
  final String utilisateurUuid;
  final String? nom;
  final String? prenom;
  final String typeIdentification;
  final String dateRepas;
  final String heureRepas;
  final String? categorieNom;

  const RecentRegistrationItem({
    required this.uuid,
    required this.utilisateurUuid,
    this.nom,
    this.prenom,
    required this.typeIdentification,
    required this.dateRepas,
    required this.heureRepas,
    this.categorieNom,
  });

  String get displayName => '${prenom ?? ""} ${nom ?? ""}'.trim();
}

class DashboardStats {
  final Map<String, dynamic> overview;
  final List<MealCountByDate> mealsPerDay;
  final List<MealDistributionItem> mealDistribution;
  final List<UserTypeDistributionItem> userTypeDistribution;
  final List<RegistrationMethodItem> registrationMethods;
  final List<PeakHourItem> peakHours;
  final List<RecentRegistrationItem> recentRegistrations;

  const DashboardStats({
    required this.overview,
    required this.mealsPerDay,
    required this.mealDistribution,
    required this.userTypeDistribution,
    required this.registrationMethods,
    required this.peakHours,
    required this.recentRegistrations,
  });

  int get mealsToday => overview['meals_today'] as int? ?? 0;
  int get mealsThisWeek => overview['meals_this_week'] as int? ?? 0;
  int get mealsThisMonth => overview['meals_this_month'] as int? ?? 0;
  int get employees => overview['employees'] as int? ?? 0;
  int get interns => overview['interns'] as int? ?? 0;
  int get visitors => overview['visitors'] as int? ?? 0;
  int get qrToday => overview['qr_registrations_today'] as int? ?? 0;
  int get faceToday => overview['face_registrations_today'] as int? ?? 0;
  int get activeQrCodes => overview['active_qr_codes'] as int? ?? 0;
  int get expiredQrCodes => overview['expired_qr_codes'] as int? ?? 0;
}
