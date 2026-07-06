import 'package:dio/dio.dart';

import 'package:mobile_app/core/errors/failures.dart';

Failure mapDioError(DioException e, {String resourceName = 'Ressource'}) {
  final statusCode = e.response?.statusCode;
  final data = e.response?.data;
  final message = data is Map ? (data['message'] as String?) : null;

  if (e.type == DioExceptionType.connectionError ||
      e.type == DioExceptionType.connectionTimeout ||
      e.type == DioExceptionType.receiveTimeout ||
      e.type == DioExceptionType.sendTimeout) {
    return const NetworkFailure(
      message: 'Impossible de contacter le serveur.',
    );
  }

  if (statusCode == 401) {
    return const UnauthorizedFailure();
  }

  if (statusCode == 404) {
    return NotFoundFailure(message: message ?? '$resourceName introuvable.');
  }

  if (statusCode == 409) {
    return ApiFailure(
      message: message ?? 'Conflit: ce $resourceName existe déjà.',
      statusCode: statusCode,
    );
  }

  if (statusCode == 422) {
    final errors = data is Map ? data['errors'] as Map<String, dynamic>? : null;
    return ValidationFailure(
      message: message ?? 'Données invalides.',
      fieldErrors: errors?.map(
            (k, v) => MapEntry(k, v is List ? v.join(', ') : v.toString()),
          ) ??
          {},
    );
  }

  if (statusCode != null && statusCode >= 500) {
    return ServerFailure(
      message: message ?? 'Erreur interne du serveur.',
      statusCode: statusCode,
    );
  }

  return ApiFailure(
    message: message ?? 'Erreur lors de la communication avec le serveur.',
    statusCode: statusCode,
  );
}
