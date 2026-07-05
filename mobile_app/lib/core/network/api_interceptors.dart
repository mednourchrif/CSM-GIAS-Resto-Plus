import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

final class ApiLoggerInterceptor extends Interceptor {
  final Logger _logger;

  ApiLoggerInterceptor({required Logger logger}) : _logger = logger;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.d('--> ${options.method} ${options.path}');
    _logger.d('Headers: ${options.headers}');
    if (options.data != null) {
      _logger.d('Body: ${options.data}');
    }
    _logger.d('--> END ${options.method}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.d('<-- ${response.statusCode} ${response.requestOptions.path}');
    _logger.d('Headers: ${response.headers}');
    _logger.d('<-- END HTTP');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e('<-- ${err.type} ${err.message}');
    _logger.e('Path: ${err.requestOptions.path}');
    if (err.response != null) {
      _logger.e('Status: ${err.response?.statusCode}');
      _logger.e('Data: ${err.response?.data}');
    }
    _logger.e('<-- END ERROR');
    handler.next(err);
  }
}

final class ApiErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }
}
