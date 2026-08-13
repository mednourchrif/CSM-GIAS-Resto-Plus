import '../../../receipts/domain/entities/receipt.dart';

class MealRegistration {
  final String? userName;
  final String mealLabel;
  final DateTime registeredAt;
  final String identificationMethod;
  final Receipt? receipt;

  const MealRegistration({
    this.userName,
    required this.mealLabel,
    required this.registeredAt,
    required this.identificationMethod,
    this.receipt,
  });
}
