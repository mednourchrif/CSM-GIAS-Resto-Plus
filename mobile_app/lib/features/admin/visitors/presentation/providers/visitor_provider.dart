import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../providers.dart';
import '../../data/datasources/visitor_remote_datasource.dart';
import '../../data/repositories/visitor_repository_impl.dart';
import '../../domain/entities/visitor.dart';
import '../../domain/repositories/visitor_repository.dart';
import 'visitor_state.dart';

final visitorRemoteDataSourceProvider = Provider<VisitorRemoteDataSource>((ref) {
  return VisitorRemoteDataSource(dio: ref.watch(apiClientProvider).dio);
});

final visitorRepositoryProvider = Provider<VisitorRepository>((ref) {
  return VisitorRepositoryImpl(
    dataSource: ref.watch(visitorRemoteDataSourceProvider),
  );
});

final visitorProvider =
    StateNotifierProvider<VisitorNotifier, VisitorState>((ref) {
  return VisitorNotifier(ref);
});

class VisitorNotifier extends StateNotifier<VisitorState> {
  final Ref _ref;
  int _refreshVersion = 0;

  VisitorNotifier(this._ref) : super(const VisitorState());

  VisitorRepository get _repo => _ref.read(visitorRepositoryProvider);

  Future<void> loadVisitors({bool refresh = false}) async {
    if (!refresh && state.isLoading) return;

    final loadPage = refresh ? 1 : state.page;
    final version = ++_refreshVersion;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      page: loadPage,
      visitors: refresh ? [] : state.visitors,
    );

    final result = await _repo.getVisitors(
      page: loadPage,
      pageSize: 20,
      search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
    );

    if (version != _refreshVersion) return;

    result.when(
      success: (paginated) {
        state = state.copyWith(
          isLoading: false,
          visitors: refresh
              ? paginated.items
              : [...state.visitors, ...paginated.items],
          total: paginated.total,
          totalPages: paginated.totalPages,
          page: paginated.page,
        );
      },
      failure: (failure) {
        state = state.copyWith(
          isLoading: false,
          visitors: refresh ? [] : state.visitors,
          error: failure.message,
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(page: state.page + 1);
    await loadVisitors();
  }

  Future<void> search(String query) async {
    state = state.copyWith(searchQuery: query, page: 1);
    await loadVisitors(refresh: true);
  }

  Future<void> refresh() async {
    await loadVisitors(refresh: true);
  }

  Future<Visitor?> getVisitor(String uuid) async {
    final result = await _repo.getVisitor(uuid);
    return result.when(
      success: (visitor) {
        state = state.copyWith(selectedVisitor: visitor);
        return visitor;
      },
      failure: (failure) {
        state = state.copyWith(error: failure.message);
        return null;
      },
    );
  }

  Future<bool> createVisitor({
    required String nom,
    required String prenom,
    String? email,
    String? societe,
    required DateTime dateVisite,
    String? statut,
  }) async {
    final result = await _repo.createVisitor(
      nom: nom,
      prenom: prenom,
      email: email,
      societe: societe,
      dateVisite: dateVisite,
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

  Future<bool> updateVisitor(
    String uuid, {
    String? nom,
    String? prenom,
    String? email,
    String? societe,
    DateTime? dateVisite,
    String? statut,
  }) async {
    final result = await _repo.updateVisitor(
      uuid,
      nom: nom,
      prenom: prenom,
      email: email,
      societe: societe,
      dateVisite: dateVisite,
      statut: statut,
    );

    return result.when(
      success: (visitor) {
        state = state.copyWith(selectedVisitor: visitor);
        refresh();
        return true;
      },
      failure: (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
    );
  }

  Future<bool> deleteVisitor(String uuid) async {
    final result = await _repo.deleteVisitor(uuid);

    return result.when(
      success: (_) {
        state = state.copyWith(
          selectedVisitor: null,
          visitors: state.visitors.where((v) => v.uuid != uuid).toList(),
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
