import 'package:dio/dio.dart';

import '../dto/dashboard_stats_dto.dart';

class StatisticsRemoteDataSource {
  final Dio _dio;

  StatisticsRemoteDataSource({required this._dio});

  Future<DashboardStatsDto> getDashboardStats() async {
    final response = await _dio.get('/stats/dashboard');
    return DashboardStatsDto.fromJson(response.data as Map<String, dynamic>);
  }
}
