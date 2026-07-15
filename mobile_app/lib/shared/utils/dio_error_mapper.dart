import 'package:dio/dio.dart';
import 'package:universal_platform/universal_platform.dart';

import 'package:mobile_app/core/errors/failures.dart';

Failure mapDioError(DioException e, {String resourceName = 'Ressource'}) {
  final statusCode = e.response?.statusCode;
  final data = e.response?.data;
  final message = data is Map ? (data['message'] as String?) : null;

  if (UniversalPlatform.isWeb) {
    final uri = e.requestOptions.uri;
    final isLocalhost = uri.host == 'localhost' || uri.host == '127.0.0.1';
    if (isLocalhost &&
        (e.type == DioExceptionType.connectionError ||
            e.type == DioExceptionType.unknown)) {
      return const NetworkFailure(
        message: 'Connexion au serveur bloquée par le navigateur (CORS).',
      );
    }
  }

  switch (e.type) {
    case DioExceptionType.connectionTimeout:
      return const NetworkFailure(
        message: 'Délai de connexion dépassé. Vérifiez votre réseau.',
      );
    case DioExceptionType.sendTimeout:
      return const NetworkFailure(
        message: "Délai d'envoi dépassé. Vérifiez votre réseau.",
      );
    case DioExceptionType.receiveTimeout:
      return const NetworkFailure(
        message: 'Délai de réponse dépassé. Vérifiez votre réseau.',
      );
    case DioExceptionType.connectionError:
      return const NetworkFailure(
        message:
            'Impossible de contacter le serveur. Vérifiez votre connexion.',
      );
    case DioExceptionType.cancel:
      return const NetworkFailure(message: 'Requête annulée.');
    case DioExceptionType.badCertificate:
      return const NetworkFailure(
        message: 'Certificat de sécurité invalide.',
      );
    case DioExceptionType.badResponse:
      break;
    case DioExceptionType.transformTimeout:
      return const NetworkFailure(
        message: 'Délai de transformation dépassé.',
      );
    case DioExceptionType.unknown:
      return const NetworkFailure(
        message: 'Erreur réseau. Veuillez réessayer.',
      );
  }

  if (statusCode == 401) {
    return const UnauthorizedFailure();
  }

  if (statusCode == 403) {
    return ApiFailure(
      message: message ?? "Accès refusé. Vous n'avez pas les droits.",
      statusCode: statusCode,
    );
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
