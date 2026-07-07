import 'package:dio/dio.dart';

class ReportRemoteDataSource {
  final Dio _dio;

  ReportRemoteDataSource({required Dio dio}) : _dio = dio;

  Future<Map<String, dynamic>> generate(Map<String, dynamic> params) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/reports/generate',
      queryParameters: params,
    );
    return response.data!;
  }
}
