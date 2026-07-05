import 'package:dio/dio.dart';

import '../../../../core/storage/storage_service.dart';

final class AuthInterceptor extends Interceptor {
  final StorageService _storageService;
  final void Function()? onUnauthorized;

  AuthInterceptor({
    required StorageService storageService,
    this.onUnauthorized,
  }) : _storageService = storageService;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!options.path.contains('/auth/login')) {
      final token = await _storageService.read(key: _tokenKey);
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      onUnauthorized?.call();
    }
    handler.next(err);
  }
}

const _tokenKey = 'auth_token';
