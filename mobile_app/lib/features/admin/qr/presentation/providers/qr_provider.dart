import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../providers.dart';
import '../../data/datasources/qr_remote_datasource.dart';
import '../../data/repositories/qr_repository_impl.dart';
import '../../domain/entities/qr_code.dart';
import '../../domain/repositories/qr_repository.dart';
import 'qr_state.dart';

final qrRemoteDataSourceProvider = Provider<QrRemoteDataSource>((ref) {
  return QrRemoteDataSource(dio: ref.watch(apiClientProvider).dio);
});

final qrRepositoryProvider = Provider<QrRepository>((ref) {
  return QrRepositoryImpl(
    dataSource: ref.watch(qrRemoteDataSourceProvider),
  );
});

final qrProvider = StateNotifierProvider<QrNotifier, QrState>((ref) {
  return QrNotifier(ref);
});

class QrNotifier extends StateNotifier<QrState> {
  final Ref _ref;
  int _refreshVersion = 0;

  QrNotifier(this._ref) : super(const QrState());

  QrRepository get _repo => _ref.read(qrRepositoryProvider);

  Future<void> loadQrCodes({bool refresh = false}) async {
    if (!refresh && state.isLoading) return;

    final loadPage = refresh ? 1 : state.page;
    final version = ++_refreshVersion;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      page: loadPage,
      qrCodes: refresh ? [] : state.qrCodes,
    );

    final result = await _repo.getQrCodes(
      page: loadPage,
      pageSize: 20,
      search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
      typeFilter: state.typeFilter,
      statusFilter: state.statusFilter,
    );

    if (version != _refreshVersion) return;

    result.when(
      success: (paginated) {
        state = state.copyWith(
          isLoading: false,
          qrCodes: refresh
              ? paginated.items
              : [...state.qrCodes, ...paginated.items],
          total: paginated.total,
          totalPages: paginated.totalPages,
          page: paginated.page,
        );
      },
      failure: (failure) {
        state = state.copyWith(
          isLoading: false,
          qrCodes: refresh ? [] : state.qrCodes,
          error: failure.message,
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(page: state.page + 1);
    await loadQrCodes();
  }

  Future<void> search(String query) async {
    state = state.copyWith(searchQuery: query, page: 1);
    await loadQrCodes(refresh: true);
  }

  Future<void> setTypeFilter(String? type) async {
    state = state.copyWith(typeFilter: type, page: 1);
    await loadQrCodes(refresh: true);
  }

  Future<void> setStatusFilter(String? status) async {
    state = state.copyWith(statusFilter: status, page: 1);
    await loadQrCodes(refresh: true);
  }

  Future<void> refresh() async {
    await loadQrCodes(refresh: true);
  }

  Future<QrCode?> getQrCode(String uuid) async {
    final result = await _repo.getQrCode(uuid);
    return result.when(
      success: (qr) {
        state = state.copyWith(selectedQrCode: qr);
        return qr;
      },
      failure: (failure) {
        state = state.copyWith(error: failure.message);
        return null;
      },
    );
  }

  Future<QrCode?> generateInternQr(String internUuid) async {
    final result = await _repo.generateInternQr(internUuid);
    return result.when(
      success: (qr) {
        refresh();
        return qr;
      },
      failure: (failure) {
        state = state.copyWith(error: failure.message);
        return null;
      },
    );
  }

  Future<QrCode?> generateVisitorQr(String visitorUuid) async {
    final result = await _repo.generateVisitorQr(visitorUuid);
    return result.when(
      success: (qr) {
        refresh();
        return qr;
      },
      failure: (failure) {
        state = state.copyWith(error: failure.message);
        return null;
      },
    );
  }

  Future<bool> revokeQr(String uuid) async {
    final result = await _repo.revokeQr(uuid);
    return result.when(
      success: (qr) {
        state = state.copyWith(selectedQrCode: qr);
        refresh();
        return true;
      },
      failure: (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
    );
  }

  Future<QrCode?> regenerateQr(String ownerUuid,
      {String ownerType = 'STAGIAIRE'}) async {
    final result = await _repo.regenerateQr(ownerUuid, ownerType: ownerType);
    return result.when(
      success: (qr) {
        refresh();
        return qr;
      },
      failure: (failure) {
        state = state.copyWith(error: failure.message);
        return null;
      },
    );
  }

  Future<List<int>?> downloadQr(String uuid) async {
    final result = await _repo.downloadQr(uuid);
    return result.when(
      success: (bytes) => bytes,
      failure: (failure) {
        state = state.copyWith(error: failure.message);
        return null;
      },
    );
  }

  Future<List<QrCode>?> getQrHistory(String ownerUuid) async {
    final result = await _repo.getQrHistory(ownerUuid);
    return result.when(
      success: (history) => history,
      failure: (failure) {
        state = state.copyWith(error: failure.message);
        return null;
      },
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}
