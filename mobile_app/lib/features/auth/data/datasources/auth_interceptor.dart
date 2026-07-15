import 'package:dio/dio.dart';

final class AuthInterceptor extends Interceptor {
  String? _cachedToken;
  final void Function()? onUnauthorized;

  AuthInterceptor({
    String? initialToken,
    this.onUnauthorized,
  }) : _cachedToken = initialToken;

  void updateToken(String? token) {
    _cachedToken = token;
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final isPublic = options.path.contains('/auth/login') ||
        options.path.contains('/meals/register');
    if (!isPublic && _cachedToken != null && _cachedToken!.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $_cachedToken';
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
