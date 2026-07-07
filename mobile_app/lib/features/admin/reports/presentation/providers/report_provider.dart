import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../providers.dart';
import '../../data/datasources/report_remote_datasource.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../../domain/repositories/report_repository.dart';
import '../../domain/entities/report_filter.dart';
import 'report_state.dart';

final reportRemoteDataSourceProvider = Provider<ReportRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ReportRemoteDataSource(dio: apiClient.dio);
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepositoryImpl(
    dataSource: ref.watch(reportRemoteDataSourceProvider),
  );
});

final reportProvider = StateNotifierProvider<ReportNotifier, ReportState>((ref) {
  return ReportNotifier(ref.watch(reportRepositoryProvider));
});

class ReportNotifier extends StateNotifier<ReportState> {
  final ReportRepository _repository;

  ReportNotifier(this._repository) : super(const ReportState());

  Future<void> generate({ReportFilter? filter}) async {
    final f = filter ?? state.filter;
    state = state.copyWith(isLoading: true, error: null, clearReport: true);

    final result = await _repository.generate(f);
    result.when(
      success: (report) {
        state = state.copyWith(
          isLoading: false,
          report: report,
          filter: f,
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

  void updateFilter(ReportFilter filter) {
    state = state.copyWith(filter: filter);
  }

  void setExporting(bool value) {
    state = state.copyWith(isExporting: value);
  }

  void setExportSuccess(String message) {
    state = state.copyWith(isExporting: false, exportSuccess: message);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void clearExportSuccess() {
    state = state.copyWith(clearExportSuccess: true);
  }
}
