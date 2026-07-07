import '../../../../../shared/models/result.dart';
import '../entities/user.dart';

abstract class AdminUserRepository {
  Future<Result<PaginatedAdminUsers>> getUsers({
    required int page,
    required int pageSize,
    String? search,
    String? sort,
    String? order,
    String? typeFilter,
    String? statutFilter,
  });

  Future<Result<AdminUser>> getUser(String uuid);

  Future<Result<AdminUser>> createUser({
    required String nom,
    required String prenom,
    required String email,
    required String motDePasse,
    required String type,
    int? roleId,
  });

  Future<Result<AdminUser>> updateUser(
    String uuid, {
    String? nom,
    String? prenom,
    String? email,
    String? statut,
    int? roleId,
  });

  Future<Result<void>> resetPassword(String uuid, String motDePasse);

  Future<Result<AdminUser>> setStatus(String uuid, String statut);

  Future<Result<void>> deleteUser(String uuid);
}
