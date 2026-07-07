import 'package:dio/dio.dart';

import '../dto/setting_dto.dart';

class SettingsRemoteDataSource {
  final Dio _dio;

  SettingsRemoteDataSource({required Dio dio}) : _dio = dio;

  Future<SettingsResponseDto> getSettings() async {
    final response = await _dio.get<Map<String, dynamic>>('/settings');
    final data = response.data!['data'] as Map<String, dynamic>;
    return SettingsResponseDto.fromJson(data);
  }

  Future<SettingsResponseDto> updateSettings(Map<String, String> settings) async {
    final response = await _dio.put<Map<String, dynamic>>('/settings', data: {'settings': settings});
    final data = response.data!['data'] as Map<String, dynamic>;
    return SettingsResponseDto.fromJson(data);
  }

  Future<SettingsResponseDto> resetToDefaults() async {
    final response = await _dio.post<Map<String, dynamic>>('/settings/reset');
    final data = response.data!['data'] as Map<String, dynamic>;
    return SettingsResponseDto.fromJson(data);
  }

  Future<VersionInfoDto> getVersion() async {
    final response = await _dio.get<Map<String, dynamic>>('/settings/version');
    final data = response.data!['data'] as Map<String, dynamic>;
    return VersionInfoDto.fromJson(data);
  }

  Future<DatabaseStatusDto> getDatabaseStatus() async {
    final response = await _dio.get<Map<String, dynamic>>('/settings/database');
    final data = response.data!['data'] as Map<String, dynamic>;
    return DatabaseStatusDto.fromJson(data);
  }
}
