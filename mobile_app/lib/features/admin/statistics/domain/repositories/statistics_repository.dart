import '../entities/dashboard_stats.dart';

abstract class StatisticsRepository {
  Future<DashboardStats> getDashboardStats();
}
