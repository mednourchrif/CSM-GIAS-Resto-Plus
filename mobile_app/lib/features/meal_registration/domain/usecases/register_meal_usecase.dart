import '../../../../shared/models/result.dart';
import '../entities/meal_registration.dart';
import '../repositories/meal_repository.dart';

class RegisterMealUseCase {
  final MealRepository _repository;

  RegisterMealUseCase(this._repository);

  Future<Result<MealRegistration>> call({
    required String identificationToken,
    required String categorieUuid,
  }) {
    return _repository.registerMeal(
      identificationToken: identificationToken,
      categorieUuid: categorieUuid,
    );
  }
}
