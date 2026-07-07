import 'package:dio/dio.dart';

import '../dto/dashboard_stats_dto.dart';

class StatisticsRemoteDataSource {
  final Dio _dio;

  StatisticsRemoteDataSource({required Dio dio}) : _dio = dio;

  Future<DashboardStatsDto> getDashboardStats() async {
    final response = await _dio.get('/stats/dashboard');
    return DashboardStatsDto.fromJson(response.data as Map<String, dynamic>);
  }
}
