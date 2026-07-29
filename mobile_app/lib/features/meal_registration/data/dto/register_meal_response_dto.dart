import '../../domain/entities/meal_registration.dart';

class RegisterMealResponseDto {
  final String? userName;
  final String meal;
  final DateTime registeredAt;
  final String identificationMethod;

  const RegisterMealResponseDto({
    this.userName,
    required this.meal,
    required this.registeredAt,
    required this.identificationMethod,
  });

  factory RegisterMealResponseDto.fromJson(Map<String, dynamic> json) {
    return RegisterMealResponseDto(
      meal: json['categorie_nom'] as String? ?? json['meal'] as String? ?? '',
      registeredAt:
          DateTime.tryParse(json['heure_repas'] as String? ?? '') ??
          DateTime.tryParse(json['registered_at'] as String? ?? '') ??
          DateTime.now(),
      identificationMethod: json['type_identification'] as String? ?? 'QR',
    );
  }

  MealRegistration toDomain() => MealRegistration(
    userName: userName,
    mealLabel: meal,
    registeredAt: registeredAt,
    identificationMethod: identificationMethod,
  );
}
