import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../providers.dart';
import '../../../../../shared/models/result.dart';
import '../../data/datasources/user_remote_datasource.dart';
import '../../data/repositories/user_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import 'user_state.dart';

final adminUserRemoteDataSourceProvider = Provider<AdminUserRemoteDataSource>((ref) {
  return AdminUserRemoteDataSource(dio: ref.watch(apiClientProvider).dio);
});

final adminUserRepositoryProvider = Provider<AdminUserRepository>((ref) {
  return AdminUserRepositoryImpl(
    dataSource: ref.watch(adminUserRemoteDataSourceProvider),
  );
});

final adminUserProvider =
    StateNotifierProvider<AdminUserNotifier, AdminUserState>((ref) {
  return AdminUserNotifier(ref);
});

class AdminUserNotifier extends StateNotifier<AdminUserState> {
  final Ref _ref;
  int _refreshVersion = 0;

  AdminUserNotifier(this._ref) : super(const AdminUserState());

  AdminUserRepository get _repo =>
      _ref.read(adminUserRepositoryProvider);

  Future<void> loadUsers({bool refresh = false}) async {
    if (!refresh && state.isLoading) return;

    final loadPage = refresh ? 1 : state.page;
    final version = ++_refreshVersion;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      page: loadPage,
    );

    final result = await _repo.getUsers(
      page: loadPage,
      pageSize: 20,
      search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      typeFilter: state.typeFilter,
      statutFilter: state.statutFilter,
    );

    if (version != _refreshVersion) return;

    result.when(
      success: (paginated) {
        state = state.copyWith(
          isLoading: false,
          users: refresh
              ? paginated.items
              : [...state.users, ...paginated.items],
          total: paginated.total,
          totalPages: paginated.totalPages,
          page: paginated.page,
        );
      },
      failure: (failure) {
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(page: state.page + 1);
    await loadUsers();
  }

  Future<void> search(String query) async {
    state = state.copyWith(searchQuery: query, page: 1);
    await loadUsers(refresh: true);
  }

  Future<void> refresh() async {
    await loadUsers(refresh: true);
  }

  Future<void> setTypeFilter(String? typeFilter) async {
    state = state.copyWith(typeFilter: typeFilter, page: 1);
    await loadUsers(refresh: true);
  }

  Future<void> setStatutFilter(String? statutFilter) async {
    state = state.copyWith(statutFilter: statutFilter, page: 1);
    await loadUsers(refresh: true);
  }

  Future<bool> createUser({
    required String nom,
    required String prenom,
    required String email,
    required String motDePasse,
    required String type,
    int? roleId,
  }) async {
    final result = await _repo.createUser(
      nom: nom,
      prenom: prenom,
      email: email,
      motDePasse: motDePasse,
      type: type,
      roleId: roleId,
    );

    if (result is Success) {
      final newUser = (result as Success<AdminUser>).data;
      state = state.copyWith(
        users: [newUser, ...state.users],
        total: state.total + 1,
      );
      await refresh();
      state = state.copyWith(
        notification: (message: 'Utilisateur créé avec succès.', isError: false),
      );
      return true;
    }

    final failure = (result as Fail).failure;
    state = state.copyWith(
      notification: (message: failure.message, isError: true),
    );
    return false;
  }

  Future<bool> updateUser(
    String uuid, {
    String? nom,
    String? prenom,
    String? email,
    String? statut,
    int? roleId,
  }) async {
    final result = await _repo.updateUser(
      uuid,
      nom: nom,
      prenom: prenom,
      email: email,
      statut: statut,
      roleId: roleId,
    );

    if (result is Success) {
      await refresh();
      state = state.copyWith(
        notification: (message: 'Utilisateur modifié avec succès.', isError: false),
      );
      return true;
    }

    final failure = (result as Fail).failure;
    state = state.copyWith(
      notification: (message: failure.message, isError: true),
    );
    return false;
  }

  Future<bool> resetPassword(String uuid, String motDePasse) async {
    final result = await _repo.resetPassword(uuid, motDePasse);

    if (result is Success) {
      state = state.copyWith(
        notification: (message: 'Mot de passe réinitialisé avec succès.', isError: false),
      );
      return true;
    }

    final failure = (result as Fail).failure;
    state = state.copyWith(
      notification: (message: failure.message, isError: true),
    );
    return false;
  }

  Future<bool> toggleStatus(String uuid, String statut) async {
    final result = await _repo.setStatus(uuid, statut);

    if (result is Success) {
      await refresh();
      final label = statut == 'ACTIF' ? 'activé' : 'désactivé';
      state = state.copyWith(
        notification: (message: 'Utilisateur $label avec succès.', isError: false),
      );
      return true;
    }

    final failure = (result as Fail).failure;
    state = state.copyWith(
      notification: (message: failure.message, isError: true),
    );
    return false;
  }

  Future<bool> deleteUser(String uuid) async {
    final result = await _repo.deleteUser(uuid);

    if (result is Success) {
      state = state.copyWith(
        clearSelected: true,
        users: state.users.where((e) => e.uuid != uuid).toList(),
        total: state.total - 1,
      );
      await refresh();
      return true;
    }

    final failure = (result as Fail).failure;
    state = state.copyWith(
      notification: (message: failure.message, isError: true),
    );
    return false;
  }

  void clearNotification() {
    state = state.copyWith(clearNotification: true);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
