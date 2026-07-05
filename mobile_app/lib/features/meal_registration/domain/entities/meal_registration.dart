class MealRegistration {
  final String userName;
  final String mealLabel;
  final DateTime registeredAt;
  final String identificationMethod;

  const MealRegistration({
    required this.userName,
    required this.mealLabel,
    required this.registeredAt,
    required this.identificationMethod,
  });
}
