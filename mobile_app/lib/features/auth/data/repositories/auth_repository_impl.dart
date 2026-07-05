import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_platform/universal_platform.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../shared/models/result.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../dto/user_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final StorageService _storageService;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required StorageService storageService,
  })  : _remoteDataSource = remoteDataSource,
        _storageService = storageService;

  @override
  Future<Result<User>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remoteDataSource.login(
        email: email,
        password: password,
      );

      final user = response.admin.toDomain();

      await _saveSession(token: response.token.accessToken, userDto: response.admin);

      return Success(user);
    } on DioException catch (e) {
      _logDioException(e);
      return Fail(_mapDioErrorToFailure(e));
    } catch (e, s) {
      debugPrint('--- LOGIN UNEXPECTED ERROR ---');
      debugPrint('Type: ${e.runtimeType}');
      debugPrint('Error: $e');
      debugPrint('Stack: $s');
      return Fail(
        const ApiFailure(
            message: 'Une erreur est survenue lors de la connexion.'),
      );
    }
  }

  @override
  Future<Result<User>> restoreSession() async {
    try {
      final token = await getStoredToken();
      if (token == null || token.isEmpty) {
        return Fail(
          const ApiFailure(message: 'Aucune session existante.'),
        );
      }

      final meResponse = await _remoteDataSource.getMe();
      final user = meResponse.toDomain();
      await _saveSession(token: token, userDto: meResponse);

      return Success(user);
    } on DioException catch (e) {
      _logDioException(e);
      if (e.response?.statusCode == 401) {
        await clearSession();
        return Fail(const UnauthorizedFailure());
      }
      return Fail(_mapDioErrorToFailure(e));
    } on FormatException {
      await clearSession();
      return Fail(
        const ApiFailure(
            message: 'Session invalide. Veuillez vous reconnecter.'),
      );
    } catch (e) {
      debugPrint('--- RESTORE UNEXPECTED ERROR ---');
      debugPrint('Type: ${e.runtimeType}');
      debugPrint('Error: $e');
      return Fail(
        const CacheFailure(message: 'Impossible de restaurer la session.'),
      );
    }
  }

  @override
  Future<void> saveSession({required String token, required User user}) async {
    final userDto = UserDto(
      id: user.id,
      nom: user.nom,
      prenom: user.prenom,
      email: user.email,
      role: user.role,
    );
    await _saveSession(token: token, userDto: userDto);
  }

  @override
  Future<void> clearSession() async {
    await _storageService.delete(key: _tokenKey);
    await _storageService.delete(key: _userKey);
  }

  @override
  Future<String?> getStoredToken() async {
    return _storageService.read(key: _tokenKey);
  }

  Future<void> _saveSession({
    required String token,
    required UserDto userDto,
  }) async {
    await _storageService.write(key: _tokenKey, value: token);
    await _storageService.write(
      key: _userKey,
      value: jsonEncode(userDto.toJson()),
    );
  }

  void _logDioException(DioException e) {
    debugPrint('--- DIO EXCEPTION ---');
    debugPrint('Type: ${e.type}');
    debugPrint('Message: ${e.message}');
    debugPrint('Method: ${e.requestOptions.method}');
    debugPrint('URL: ${e.requestOptions.uri}');
    debugPrint('Headers: ${e.requestOptions.headers}');
    debugPrint('Body: ${e.requestOptions.data}');
    if (e.response != null) {
      debugPrint('Response status: ${e.response!.statusCode}');
      debugPrint('Response headers: ${e.response!.headers.map}');
      debugPrint('Response body: ${e.response!.data}');
    } else {
      debugPrint('Response: null (request never reached server)');
    }
    debugPrint('Original error: ${e.error}');
    debugPrint('Stack: ${e.stackTrace}');
    debugPrint('--- END DIO EXCEPTION ---');
  }

  Failure _mapDioErrorToFailure(DioException e) {
    if (UniversalPlatform.isWeb) {
      final uri = e.requestOptions.uri;
      final isLocalhost = uri.host == 'localhost' || uri.host == '127.0.0.1';
      if (isLocalhost &&
          (e.type == DioExceptionType.connectionError ||
              e.type == DioExceptionType.unknown)) {
        return const NetworkFailure(
          message: 'Connexion au serveur bloquee par le navigateur (CORS).',
        );
      }
    }

    if (e.type == DioExceptionType.connectionTimeout) {
      return const NetworkFailure(
        message: 'Delai de connexion depasse. Verifiez votre reseau.',
      );
    }
    if (e.type == DioExceptionType.sendTimeout) {
      return const NetworkFailure(
        message: "Delai d'envoi depasse. Verifiez votre reseau.",
      );
    }
    if (e.type == DioExceptionType.receiveTimeout) {
      return const NetworkFailure(
        message: 'Delai de reponse depasse. Verifiez votre reseau.',
      );
    }

    if (e.type == DioExceptionType.connectionError) {
      return const NetworkFailure(
        message:
            'Impossible de contacter le serveur. Verifiez votre connexion.',
      );
    }

    if (e.type == DioExceptionType.cancel) {
      return const NetworkFailure(message: 'Requete annulee.');
    }

    if (e.type == DioExceptionType.badResponse) {
      final statusCode = e.response!.statusCode;
      final data = e.response!.data;
      final message = data is Map ? (data['message'] as String?) : null;

      if (statusCode == 401) {
        return const UnauthorizedFailure();
      }
      if (statusCode == 403) {
        return ApiFailure(
          message: message ??
              "Acces refuse. Vous n'avez pas les droits necessaires.",
          statusCode: statusCode,
        );
      }
      if (statusCode == 422) {
        final errors =
            data is Map ? data['errors'] as Map<String, dynamic>? : null;
        return ValidationFailure(
          message: message ?? 'Donnees invalides.',
          fieldErrors: errors?.map(
                (k, v) => MapEntry(
                  k,
                  v is List ? v.join(', ') : v.toString(),
                ),
              ) ??
              {},
        );
      }
      if (statusCode == 404) {
        return NotFoundFailure(
          message: message ?? 'Endpoint introuvable.',
          statusCode: statusCode,
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
        errors: data is Map ? data['errors'] as Map<String, dynamic>? : null,
      );
    }

    if (e.type == DioExceptionType.badCertificate) {
      return const NetworkFailure(
        message: 'Certificat de securite invalide.',
      );
    }

    return const NetworkFailure(
      message: 'Erreur reseau. Veuillez reessayer.',
    );
  }
}

const _tokenKey = 'auth_token';
const _userKey = 'auth_user';
