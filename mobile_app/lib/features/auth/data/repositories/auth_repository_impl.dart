import 'dart:convert';

import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
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
    required this._remoteDataSource,
    required this._storageService,
  });

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

      await _saveSession(
        token: response.token.accessToken,
        userDto: response.admin,
      );

      return Success(user);
    } on DioException catch (e) {
      return Fail(mapDioError(e));
    } on CacheException catch (e) {
      return Fail(e.failure);
    } on FormatException catch (e, stackTrace) {
      return Fail(
        ApiFailure(
          message: 'Réponse de connexion invalide.',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    } catch (e, stackTrace) {
      return Fail(
        ApiFailure(
          message: 'Une erreur est survenue lors de la connexion.',
          originalError: e,
          stackTrace: stackTrace,
        ),
      );
    }
  }

  @override
  Future<Result<User>> restoreSession() async {
    try {
      final token = await getStoredToken();
      if (token == null || token.isEmpty) {
        return const Fail(ApiFailure(message: 'Aucune session existante.'));
      }

      final meResponse = await _remoteDataSource.getMe();
      final user = meResponse.toDomain();
      await _saveSession(token: token, userDto: meResponse);

      return Success(user);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await clearSession();
        return const Fail(UnauthorizedFailure());
      }
      return Fail(mapDioError(e));
    } on FormatException {
      await clearSession();
      return const Fail(
        ApiFailure(message: 'Session invalide. Veuillez vous reconnecter.'),
      );
    } on CacheException catch (e) {
      return Fail(e.failure);
    } catch (e, stackTrace) {
      return Fail(
        CacheFailure(
          message: 'Impossible de restaurer la session.',
          originalError: e,
          stackTrace: stackTrace,
        ),
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
}

const _tokenKey = 'auth_token';
const _userKey = 'auth_user';
