import 'employee.dart';

class MealSummary {
  final String uuid;
  final String categorieNom;
  final String typeIdentification;
  final DateTime dateRepas;
  final DateTime heureRepas;

  const MealSummary({
    required this.uuid,
    required this.categorieNom,
    required this.typeIdentification,
    required this.dateRepas,
    required this.heureRepas,
  });
}

class EmployeeDetail {
  final Employee employee;
  final MealSummary? todayMeal;
  final List<MealSummary> lastMeals;
  final bool faceEnrolled;
  final bool qrGenerated;

  const EmployeeDetail({
    required this.employee,
    this.todayMeal,
    this.lastMeals = const [],
    this.faceEnrolled = false,
    this.qrGenerated = false,
  });

  bool get hasTodayMeal => todayMeal != null;
  String get mealStatus => hasTodayMeal ? 'Repas enregistré' : 'Aucun repas aujourd\'hui';
}
