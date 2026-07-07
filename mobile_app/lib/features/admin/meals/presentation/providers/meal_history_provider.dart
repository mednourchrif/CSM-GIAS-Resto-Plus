import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../providers.dart';
import '../../data/datasources/meal_history_remote_datasource.dart';
import '../../data/repositories/meal_history_repository_impl.dart';
import '../../domain/repositories/meal_history_repository.dart';
import '../../domain/usecases/get_meal_history_usecase.dart';
import '../../domain/usecases/get_meal_stats_usecase.dart';
import 'meal_history_state.dart';

class MealHistoryNotifier extends StateNotifier<MealHistoryState> {
  final GetMealHistoryUseCase _getMealHistory;
  final GetMealStatsUseCase _getMealStats;

  MealHistoryNotifier(this._getMealHistory, this._getMealStats)
      : super(const MealHistoryState());

  Future<void> loadMeals({bool refresh = false}) async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final page = refresh ? 1 : state.currentPage;
      final result = await _getMealHistory(
        page: page,
        pageSize: state.pageSize,
        search: state.search,
        dateFrom: state.dateFrom,
        dateTo: state.dateTo,
        categorieUuid: state.categorieUuid,
        typeIdentification: state.typeIdentification,
        userType: state.userType,
        sort: state.sort,
        order: state.order,
      );
      state = state.copyWith(
        meals: result.items,
        totalCount: result.total,
        currentPage: result.page,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadStats() async {
    state = state.copyWith(isLoadingStats: true);
    try {
      final stats = await _getMealStats(
        dateFrom: state.dateFrom,
        dateTo: state.dateTo,
      );
      state = state.copyWith(stats: stats, isLoadingStats: false);
    } catch (e) {
      state = state.copyWith(isLoadingStats: false);
    }
  }

  Future<void> nextPage() async {
    if (!state.hasNextPage || state.isLoading) return;
    state = state.copyWith(currentPage: state.currentPage + 1);
    await loadMeals();
  }

  Future<void> previousPage() async {
    if (!state.hasPreviousPage || state.isLoading) return;
    state = state.copyWith(currentPage: state.currentPage - 1);
    await loadMeals();
  }

  void setSearch(String? search) {
    state = state.copyWith(search: search, currentPage: 1);
    loadMeals();
  }

  void setDateFilter({String? dateFrom, String? dateTo}) {
    state = state.copyWith(
      dateFrom: dateFrom,
      dateTo: dateTo,
      currentPage: 1,
    );
    loadMeals();
    loadStats();
  }

  void setCategorieFilter(String? categorieUuid) {
    state = state.copyWith(
      categorieUuid: categorieUuid,
      currentPage: 1,
    );
    loadMeals();
    loadStats();
  }

  void setTypeIdentificationFilter(String? typeIdentification) {
    state = state.copyWith(
      typeIdentification: typeIdentification,
      currentPage: 1,
    );
    loadMeals();
  }

  void setUserTypeFilter(String? userType) {
    state = state.copyWith(
      userType: userType,
      currentPage: 1,
    );
    loadMeals();
    loadStats();
  }

  void setSort(String field) {
    final order = state.sort == field && state.order == 'asc' ? 'desc' : 'asc';
    state = state.copyWith(sort: field, order: order, currentPage: 1);
    loadMeals();
  }

  void resetFilters() {
    state = const MealHistoryState();
    loadMeals();
    loadStats();
  }
}

final mealHistoryRemoteDataSourceProvider =
    Provider<MealHistoryRemoteDataSource>((ref) {
  return MealHistoryRemoteDataSource(dio: ref.watch(apiClientProvider).dio);
});

final mealHistoryRepositoryProvider = Provider<MealHistoryRepository>((ref) {
  return MealHistoryRepositoryImpl(
    ref.watch(mealHistoryRemoteDataSourceProvider),
  );
});

final getMealHistoryUseCaseProvider = Provider<GetMealHistoryUseCase>((ref) {
  return GetMealHistoryUseCase(ref.watch(mealHistoryRepositoryProvider));
});

final getMealStatsUseCaseProvider = Provider<GetMealStatsUseCase>((ref) {
  return GetMealStatsUseCase(ref.watch(mealHistoryRepositoryProvider));
});

final mealHistoryProvider =
    StateNotifierProvider<MealHistoryNotifier, MealHistoryState>((ref) {
  return MealHistoryNotifier(
    ref.watch(getMealHistoryUseCaseProvider),
    ref.watch(getMealStatsUseCaseProvider),
  );
});
