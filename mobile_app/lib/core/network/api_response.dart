import 'package:dio/dio.dart';

class ApiResponse<T> {
  final T? data;
  final String? message;
  final bool success;

  const ApiResponse({this.data, this.message, required this.success});

  factory ApiResponse.fromResponse(Response response) {
    final body = response.data as Map<String, dynamic>?;
    return ApiResponse(
      data: body?['data'] as T?,
      message: body?['message'] as String?,
      success: body?['success'] as bool? ?? true,
    );
  }
}
