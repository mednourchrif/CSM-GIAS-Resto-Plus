import '../repositories/meal_history_repository.dart';

class GetMealHistoryUseCase {
  final MealHistoryRepository _repository;

  GetMealHistoryUseCase(this._repository);

  Future<PaginatedMealResult> call({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? dateFrom,
    String? dateTo,
    String? categorieUuid,
    String? typeIdentification,
    String? userType,
    String? sort,
    String order = 'desc',
  }) {
    return _repository.getMealHistory(
      page: page,
      pageSize: pageSize,
      search: search,
      dateFrom: dateFrom,
      dateTo: dateTo,
      categorieUuid: categorieUuid,
      typeIdentification: typeIdentification,
      userType: userType,
      sort: sort,
      order: order,
    );
  }
}
