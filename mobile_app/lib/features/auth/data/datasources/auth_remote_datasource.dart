import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/network/api_response.dart';
import '../dto/login_request_dto.dart';
import '../dto/login_response_dto.dart';
import '../dto/user_dto.dart';

class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource({required Dio dio}) : _dio = dio;

  Future<LoginResponseDto> login({
    required String email,
    required String password,
  }) async {
    final request = LoginRequestDto(email: email, motDePasse: password);
    debugPrint('--- AUTH LOGIN REQUEST ---');
    debugPrint('URL: ${_dio.options.baseUrl}/auth/login');
    debugPrint('Method: POST');
    debugPrint('Headers: ${_dio.options.headers}');
    debugPrint('Body: ${request.toJson()}');

    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: request.toJson(),
    );

    debugPrint('--- AUTH LOGIN RESPONSE ---');
    debugPrint('Status: ${response.statusCode}');
    debugPrint('Headers: ${response.headers.map}');
    debugPrint('Body: ${response.data}');

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromResponse(response);
    return LoginResponseDto.fromJson(apiResponse.data!);
  }

  Future<UserDto> getMe() async {
    debugPrint('--- AUTH ME REQUEST ---');
    debugPrint('URL: ${_dio.options.baseUrl}/auth/me');
    debugPrint('Method: GET');
    debugPrint('Headers: ${_dio.options.headers}');

    final response = await _dio.get<Map<String, dynamic>>('/auth/me');

    debugPrint('--- AUTH ME RESPONSE ---');
    debugPrint('Status: ${response.statusCode}');
    debugPrint('Body: ${response.data}');

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromResponse(response);
    return UserDto.fromJson(apiResponse.data!['admin'] as Map<String, dynamic>);
  }
}
