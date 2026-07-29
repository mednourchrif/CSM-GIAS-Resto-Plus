import 'package:dio/dio.dart';

import '../../../../core/network/api_response.dart';
import '../dto/login_request_dto.dart';
import '../dto/login_response_dto.dart';
import '../dto/user_dto.dart';

class AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSource({required this._dio});

  Future<LoginResponseDto> login({
    required String email,
    required String password,
  }) async {
    final request = LoginRequestDto(email: email, motDePasse: password);

    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: request.toJson(),
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromResponse(
      response,
    );
    final data = apiResponse.data;
    if (data == null) {
      throw const FormatException('Missing login response data.');
    }
    return LoginResponseDto.fromJson(data);
  }

  Future<UserDto> getMe() async {
    final response = await _dio.get<Map<String, dynamic>>('/auth/me');

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromResponse(
      response,
    );
    final data = apiResponse.data;
    if (data == null) {
      throw const FormatException('Missing current-user response data.');
    }
    return UserDto.fromJson(data);
  }
}
