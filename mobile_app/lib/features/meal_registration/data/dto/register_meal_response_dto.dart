import '../../domain/entities/meal_registration.dart';
import '../../../receipts/domain/entities/receipt.dart';

class RegisterMealResponseDto {
  final String? userName;
  final String meal;
  final DateTime registeredAt;
  final String identificationMethod;
  final Receipt? receipt;

  const RegisterMealResponseDto({
    this.userName,
    required this.meal,
    required this.registeredAt,
    required this.identificationMethod,
    this.receipt,
  });

  factory RegisterMealResponseDto.fromJson(Map<String, dynamic> json) {
    final receiptJson = json['receipt'];
    final receipt = receiptJson is Map<String, dynamic>
        ? Receipt.fromJson(receiptJson)
        : null;
    return RegisterMealResponseDto(
      meal: json['categorie_nom'] as String? ?? json['meal'] as String? ?? '',
      registeredAt:
          DateTime.tryParse(json['heure_repas'] as String? ?? '') ??
          DateTime.tryParse(json['registered_at'] as String? ?? '') ??
          DateTime.now(),
      identificationMethod: json['type_identification'] as String? ?? 'QR',
      receipt: receipt,
    );
  }

  MealRegistration toDomain() => MealRegistration(
    userName: userName,
    mealLabel: meal,
    registeredAt: registeredAt,
    identificationMethod: identificationMethod,
    receipt: receipt,
  );
}
