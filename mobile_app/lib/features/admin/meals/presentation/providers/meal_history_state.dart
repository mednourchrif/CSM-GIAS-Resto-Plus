import '../../domain/entities/meal_history.dart';

class MealHistoryState {
  final List<MealHistory> meals;
  final MealStats? stats;
  final bool isLoading;
  final bool isLoadingStats;
  final String? error;
  final int currentPage;
  final int totalCount;
  final int pageSize;
  final String? search;
  final String? dateFrom;
  final String? dateTo;
  final String? categorieUuid;
  final String? typeIdentification;
  final String? userType;
  final String sort;
  final String order;

  const MealHistoryState({
    this.meals = const [],
    this.stats,
    this.isLoading = false,
    this.isLoadingStats = false,
    this.error,
    this.currentPage = 1,
    this.totalCount = 0,
    this.pageSize = 20,
    this.search,
    this.dateFrom,
    this.dateTo,
    this.categorieUuid,
    this.typeIdentification,
    this.userType,
    this.sort = 'date_repas',
    this.order = 'desc',
  });

  MealHistoryState copyWith({
    List<MealHistory>? meals,
    MealStats? stats,
    bool? isLoading,
    bool? isLoadingStats,
    String? error,
    int? currentPage,
    int? totalCount,
    int? pageSize,
    String? search,
    String? dateFrom,
    String? dateTo,
    String? categorieUuid,
    String? typeIdentification,
    String? userType,
    String? sort,
    String? order,
    bool clearError = false,
  }) {
    return MealHistoryState(
      meals: meals ?? this.meals,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      isLoadingStats: isLoadingStats ?? this.isLoadingStats,
      error: clearError ? null : error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      pageSize: pageSize ?? this.pageSize,
      search: search ?? this.search,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      categorieUuid: categorieUuid ?? this.categorieUuid,
      typeIdentification: typeIdentification ?? this.typeIdentification,
      userType: userType ?? this.userType,
      sort: sort ?? this.sort,
      order: order ?? this.order,
    );
  }

  int get totalPages => (totalCount + pageSize - 1) ~/ pageSize;
  bool get hasNextPage => currentPage < totalPages;
  bool get hasPreviousPage => currentPage > 1;
  bool get hasActiveFilters =>
      search != null ||
      dateFrom != null ||
      dateTo != null ||
      categorieUuid != null ||
      typeIdentification != null ||
      userType != null;
}
