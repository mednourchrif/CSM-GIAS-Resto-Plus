import '../entities/meal_history.dart';
import '../repositories/meal_history_repository.dart';

class GetMealStatsUseCase {
  final MealHistoryRepository _repository;

  GetMealStatsUseCase(this._repository);

  Future<MealStats> call({
    String? dateFrom,
    String? dateTo,
  }) {
    return _repository.getMealStats(
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
  }
}
