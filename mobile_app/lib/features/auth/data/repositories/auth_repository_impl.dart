import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../shared/models/result.dart';
import '../../../../shared/utils/dio_error_mapper.dart';
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
      return Fail(mapDioError(e));
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
      return Fail(mapDioError(e));
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

}

const _tokenKey = 'auth_token';
const _userKey = 'auth_user';
