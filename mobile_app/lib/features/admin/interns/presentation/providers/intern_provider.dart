import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../providers.dart';
import '../../data/datasources/intern_remote_datasource.dart';
import '../../data/repositories/intern_repository_impl.dart';
import '../../domain/entities/intern.dart';
import '../../domain/repositories/intern_repository.dart';
import 'intern_state.dart';

final internRemoteDataSourceProvider = Provider<InternRemoteDataSource>((ref) {
  return InternRemoteDataSource(dio: ref.watch(apiClientProvider).dio);
});

final internRepositoryProvider = Provider<InternRepository>((ref) {
  return InternRepositoryImpl(
    dataSource: ref.watch(internRemoteDataSourceProvider),
  );
});

final internProvider =
    StateNotifierProvider<InternNotifier, InternState>((ref) {
  return InternNotifier(ref);
});

class InternNotifier extends StateNotifier<InternState> {
  final Ref _ref;
  int _refreshVersion = 0;

  InternNotifier(this._ref) : super(const InternState());

  InternRepository get _repo => _ref.read(internRepositoryProvider);

  Future<void> loadInterns({bool refresh = false}) async {
    if (!refresh && state.isLoading) return;

    final loadPage = refresh ? 1 : state.page;
    final version = ++_refreshVersion;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      page: loadPage,
      interns: refresh ? [] : state.interns,
    );

    final result = await _repo.getInterns(
      page: loadPage,
      pageSize: 20,
      search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
    );

    if (version != _refreshVersion) return;

    result.when(
      success: (paginated) {
        state = state.copyWith(
          isLoading: false,
          interns: refresh
              ? paginated.items
              : [...state.interns, ...paginated.items],
          total: paginated.total,
          totalPages: paginated.totalPages,
          page: paginated.page,
        );
      },
      failure: (failure) {
        state = state.copyWith(
          isLoading: false,
          interns: refresh ? [] : state.interns,
          error: failure.message,
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(page: state.page + 1);
    await loadInterns();
  }

  Future<void> search(String query) async {
    state = state.copyWith(searchQuery: query, page: 1);
    await loadInterns(refresh: true);
  }

  Future<void> refresh() async {
    await loadInterns(refresh: true);
  }

  Future<Intern?> getIntern(String uuid) async {
    final result = await _repo.getIntern(uuid);
    return result.when(
      success: (intern) {
        state = state.copyWith(selectedIntern: intern);
        return intern;
      },
      failure: (failure) {
        state = state.copyWith(error: failure.message);
        return null;
      },
    );
  }

  Future<bool> createIntern({
    required String nom,
    required String prenom,
    required String matricule,
    required DateTime dateDebutStage,
    required DateTime dateFinStage,
    String? statut,
  }) async {
    final result = await _repo.createIntern(
      nom: nom,
      prenom: prenom,
      matricule: matricule,
      dateDebutStage: dateDebutStage,
      dateFinStage: dateFinStage,
      statut: statut,
    );

    return result.when(
      success: (_) {
        refresh();
        return true;
      },
      failure: (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
    );
  }

  Future<bool> updateIntern(
    String uuid, {
    String? nom,
    String? prenom,
    String? matricule,
    DateTime? dateDebutStage,
    DateTime? dateFinStage,
    String? statut,
  }) async {
    final result = await _repo.updateIntern(
      uuid,
      nom: nom,
      prenom: prenom,
      matricule: matricule,
      dateDebutStage: dateDebutStage,
      dateFinStage: dateFinStage,
      statut: statut,
    );

    return result.when(
      success: (intern) {
        state = state.copyWith(selectedIntern: intern);
        refresh();
        return true;
      },
      failure: (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
    );
  }

  Future<bool> deleteIntern(String uuid) async {
    final result = await _repo.deleteIntern(uuid);

    return result.when(
      success: (_) {
        state = state.copyWith(
          selectedIntern: null,
          interns: state.interns.where((i) => i.uuid != uuid).toList(),
          total: state.total - 1,
        );
        refresh();
        return true;
      },
      failure: (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
