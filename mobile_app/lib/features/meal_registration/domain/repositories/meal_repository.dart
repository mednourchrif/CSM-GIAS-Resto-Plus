import '../../../../shared/models/result.dart';
import '../entities/meal_category.dart';
import '../entities/meal_registration.dart';

abstract class MealRepository {
  Future<Result<MealRegistration>> registerMeal({
    String? qrToken,
    String? userUuid,
    required String categorieUuid,
  });

  Future<Result<List<MealCategory>>> getCategories();
}
