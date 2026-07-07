import '../entities/dashboard_stats.dart';
import '../repositories/statistics_repository.dart';

class GetDashboardStatsUseCase {
  final StatisticsRepository _repository;

  GetDashboardStatsUseCase(this._repository);

  Future<DashboardStats> call() {
    return _repository.getDashboardStats();
  }
}
