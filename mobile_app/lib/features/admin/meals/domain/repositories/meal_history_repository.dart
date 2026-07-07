import '../entities/meal_history.dart';

class PaginatedMealResult {
  final List<MealHistory> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  const PaginatedMealResult({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });
}

abstract class MealHistoryRepository {
  Future<PaginatedMealResult> getMealHistory({
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
  });

  Future<MealStats> getMealStats({
    String? dateFrom,
    String? dateTo,
  });
}
