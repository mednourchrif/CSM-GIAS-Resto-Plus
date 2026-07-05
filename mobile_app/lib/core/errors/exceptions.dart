import 'failures.dart';

class AppException implements Exception {
  final Failure failure;

  const AppException(this.failure);

  @override
  String toString() => failure.toString();
}

class NetworkException extends AppException {
  const NetworkException(super.failure);
}

class ApiException extends AppException {
  const ApiException(super.failure);
}

class ValidationException extends AppException {
  const ValidationException(super.failure);
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(super.failure);
}

class NotFoundException extends AppException {
  const NotFoundException(super.failure);
}

class ServerException extends AppException {
  const ServerException(super.failure);
}

class CacheException extends AppException {
  const CacheException(super.failure);
}
