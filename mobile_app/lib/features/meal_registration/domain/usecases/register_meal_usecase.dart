import '../../../../shared/models/result.dart';
import '../entities/meal_registration.dart';
import '../repositories/meal_repository.dart';

class RegisterMealUseCase {
  final MealRepository _repository;

  RegisterMealUseCase(this._repository);

  Future<Result<MealRegistration>> call({
    String? qrToken,
    String? userUuid,
    required String categorieUuid,
  }) {
    return _repository.registerMeal(
      qrToken: qrToken,
      userUuid: userUuid,
      categorieUuid: categorieUuid,
    );
  }
}
