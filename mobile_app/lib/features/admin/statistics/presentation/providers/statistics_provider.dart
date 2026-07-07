import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../providers.dart';
import '../../data/datasources/statistics_remote_datasource.dart';
import '../../data/repositories/statistics_repository_impl.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../../domain/usecases/get_dashboard_stats_usecase.dart';
import 'statistics_state.dart';

class StatisticsNotifier extends StateNotifier<StatisticsState> {
  final GetDashboardStatsUseCase _getDashboardStats;

  StatisticsNotifier(this._getDashboardStats) : super(const StatisticsState());

  Future<void> load() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, error: null);
    try {
      final stats = await _getDashboardStats();
      state = state.copyWith(stats: stats, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final statisticsRemoteDataSourceProvider =
    Provider<StatisticsRemoteDataSource>((ref) {
  return StatisticsRemoteDataSource(dio: ref.watch(apiClientProvider).dio);
});

final statisticsRepositoryProvider = Provider<StatisticsRepository>((ref) {
  return StatisticsRepositoryImpl(ref.watch(statisticsRemoteDataSourceProvider));
});

final getDashboardStatsUseCaseProvider = Provider<GetDashboardStatsUseCase>((ref) {
  return GetDashboardStatsUseCase(ref.watch(statisticsRepositoryProvider));
});

final statisticsProvider =
    StateNotifierProvider<StatisticsNotifier, StatisticsState>((ref) {
  return StatisticsNotifier(ref.watch(getDashboardStatsUseCaseProvider));
});
