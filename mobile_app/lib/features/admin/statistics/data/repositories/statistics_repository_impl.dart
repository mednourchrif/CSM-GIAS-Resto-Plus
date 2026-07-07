import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/statistics_repository.dart';
import '../datasources/statistics_remote_datasource.dart';

class StatisticsRepositoryImpl implements StatisticsRepository {
  final StatisticsRemoteDataSource _dataSource;

  StatisticsRepositoryImpl(this._dataSource);

  @override
  Future<DashboardStats> getDashboardStats() async {
    final dto = await _dataSource.getDashboardStats();
    return dto.toEntity();
  }
}
