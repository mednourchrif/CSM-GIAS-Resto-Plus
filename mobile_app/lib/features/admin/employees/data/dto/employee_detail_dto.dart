import '../../domain/entities/employee_detail.dart';
import 'employee_dto.dart';

class MealSummaryDto {
  final String uuid;
  final String categorieNom;
  final String typeIdentification;
  final String dateRepas;
  final String heureRepas;

  const MealSummaryDto({
    required this.uuid,
    required this.categorieNom,
    required this.typeIdentification,
    required this.dateRepas,
    required this.heureRepas,
  });

  factory MealSummaryDto.fromJson(Map<String, dynamic> json) {
    return MealSummaryDto(
      uuid: json['uuid'] as String,
      categorieNom: json['categorie_nom'] as String? ?? '',
      typeIdentification: json['type_identification'] as String? ?? 'QR',
      dateRepas: json['date_repas'] as String,
      heureRepas: json['heure_repas'] as String,
    );
  }

  MealSummary toDomain() => MealSummary(
        uuid: uuid,
        categorieNom: categorieNom,
        typeIdentification: typeIdentification,
        dateRepas: DateTime.tryParse(dateRepas) ?? DateTime.now(),
        heureRepas: DateTime.tryParse(heureRepas) ?? DateTime.now(),
      );
}

class EmployeeDetailDto {
  final EmployeeDto employeeDto;
  final MealSummaryDto? todayMeal;
  final List<MealSummaryDto> lastMeals;
  final bool faceEnrolled;
  final bool qrGenerated;

  const EmployeeDetailDto({
    required this.employeeDto,
    this.todayMeal,
    this.lastMeals = const [],
    this.faceEnrolled = false,
    this.qrGenerated = false,
  });

  factory EmployeeDetailDto.fromJson(Map<String, dynamic> json) {
    return EmployeeDetailDto(
      employeeDto: EmployeeDto.fromJson(json),
      todayMeal: json['today_meal'] != null
          ? MealSummaryDto.fromJson(json['today_meal'] as Map<String, dynamic>)
          : null,
      lastMeals: (json['last_meals'] as List<dynamic>?)
              ?.map((e) => MealSummaryDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      faceEnrolled: json['face_enrolled'] as bool? ?? false,
      qrGenerated: json['qr_generated'] as bool? ?? false,
    );
  }

  EmployeeDetail toDomain() => EmployeeDetail(
        employee: employeeDto.toDomain(),
        todayMeal: todayMeal?.toDomain(),
        lastMeals: lastMeals.map((e) => e.toDomain()).toList(),
        faceEnrolled: faceEnrolled,
        qrGenerated: qrGenerated,
      );
}
