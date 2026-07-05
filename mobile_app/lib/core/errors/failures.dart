abstract class Failure {
  final String message;
  final Object? originalError;
  final StackTrace? stackTrace;

  const Failure({required this.message, this.originalError, this.stackTrace});

  @override
  String toString() => 'Failure: $message';
}

class ApiFailure extends Failure {
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const ApiFailure({
    required super.message,
    this.statusCode,
    this.errors,
    super.originalError,
    super.stackTrace,
  });
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.originalError,
    super.stackTrace,
  });
}

class ValidationFailure extends Failure {
  final Map<String, String> fieldErrors;

  const ValidationFailure({
    required super.message,
    this.fieldErrors = const {},
    super.originalError,
    super.stackTrace,
  });
}

class UnauthorizedFailure extends ApiFailure {
  const UnauthorizedFailure({
    super.message = 'Session expirée. Veuillez vous reconnecter.',
    super.statusCode = 401,
    super.originalError,
    super.stackTrace,
  });
}

class NotFoundFailure extends ApiFailure {
  const NotFoundFailure({
    super.message = 'Ressource introuvable.',
    super.statusCode = 404,
    super.originalError,
    super.stackTrace,
  });
}

class ServerFailure extends ApiFailure {
  const ServerFailure({
    super.message = 'Erreur interne du serveur.',
    super.statusCode = 500,
    super.originalError,
    super.stackTrace,
  });
}

class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.originalError,
    super.stackTrace,
  });
}
