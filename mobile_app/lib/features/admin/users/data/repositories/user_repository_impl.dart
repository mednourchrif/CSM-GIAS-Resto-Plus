import 'package:dio/dio.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../shared/models/result.dart';
import '../../../../../shared/utils/dio_error_mapper.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';
import '../dto/create_user_request_dto.dart';
import '../dto/update_user_request_dto.dart';

class AdminUserRepositoryImpl implements AdminUserRepository {
  final AdminUserRemoteDataSource _dataSource;

  AdminUserRepositoryImpl({required AdminUserRemoteDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Result<PaginatedAdminUsers>> getUsers({
    required int page,
    required int pageSize,
    String? search,
    String? sort,
    String? order,
    String? typeFilter,
    String? statutFilter,
  }) async {
    try {
      final response = await _dataSource.getUsers(
        page: page,
        pageSize: pageSize,
        search: search,
        sort: sort,
        order: order,
        typeFilter: typeFilter,
        statutFilter: statutFilter,
      );
      return Success(PaginatedAdminUsers(
        items: response.items.map((e) => e.toDomain()).toList(),
        total: response.total,
        page: response.page,
        pageSize: response.pageSize,
        totalPages: response.totalPages,
      ));
    } on DioException catch (e) {
      return Fail(mapDioError(e, resourceName: 'utilisateur'));
    } catch (e) {
      return Fail(ApiFailure(message: 'Erreur lors du chargement des utilisateurs.'));
    }
  }

  @override
  Future<Result<AdminUser>> getUser(String uuid) async {
    try {
      final dto = await _dataSource.getUser(uuid);
      return Success(dto.toDomain());
    } on DioException catch (e) {
      return Fail(mapDioError(e, resourceName: 'utilisateur'));
    } catch (e) {
      return Fail(ApiFailure(message: 'Erreur lors du chargement de l\'utilisateur.'));
    }
  }

  @override
  Future<Result<AdminUser>> createUser({
    required String nom,
    required String prenom,
    required String email,
    required String motDePasse,
    required String type,
    int? roleId,
  }) async {
    try {
      final request = CreateAdminUserRequestDto(
        nom: nom,
        prenom: prenom,
        email: email,
        motDePasse: motDePasse,
        type: type,
        roleId: roleId,
      );
      final dto = await _dataSource.createUser(request);
      return Success(dto.toDomain());
    } on DioException catch (e) {
      return Fail(mapDioError(e, resourceName: 'utilisateur'));
    } catch (e) {
      return Fail(ApiFailure(message: 'Erreur lors de la création de l\'utilisateur.'));
    }
  }

  @override
  Future<Result<AdminUser>> updateUser(
    String uuid, {
    String? nom,
    String? prenom,
    String? email,
    String? statut,
    int? roleId,
  }) async {
    try {
      final request = UpdateAdminUserRequestDto(
        nom: nom,
        prenom: prenom,
        email: email,
        statut: statut,
        roleId: roleId,
      );
      final dto = await _dataSource.updateUser(uuid, request);
      return Success(dto.toDomain());
    } on DioException catch (e) {
      return Fail(mapDioError(e, resourceName: 'utilisateur'));
    } catch (e) {
      return Fail(ApiFailure(message: 'Erreur lors de la modification de l\'utilisateur.'));
    }
  }

  @override
  Future<Result<void>> resetPassword(String uuid, String motDePasse) async {
    try {
      await _dataSource.resetPassword(uuid, motDePasse);
      return const Success(null);
    } on DioException catch (e) {
      return Fail(mapDioError(e, resourceName: 'utilisateur'));
    } catch (e) {
      return Fail(ApiFailure(message: 'Erreur lors de la réinitialisation du mot de passe.'));
    }
  }

  @override
  Future<Result<AdminUser>> setStatus(String uuid, String statut) async {
    try {
      final dto = await _dataSource.setStatus(uuid, statut);
      return Success(dto.toDomain());
    } on DioException catch (e) {
      return Fail(mapDioError(e, resourceName: 'utilisateur'));
    } catch (e) {
      return Fail(ApiFailure(message: 'Erreur lors du changement de statut.'));
    }
  }

  @override
  Future<Result<void>> deleteUser(String uuid) async {
    try {
      await _dataSource.deleteUser(uuid);
      return const Success(null);
    } on DioException catch (e) {
      return Fail(mapDioError(e, resourceName: 'utilisateur'));
    } catch (e) {
      return Fail(ApiFailure(message: 'Erreur lors de la suppression de l\'utilisateur.'));
    }
  }
}
