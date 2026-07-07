import '../../domain/entities/report_entity.dart';
import '../../domain/entities/report_filter.dart';

class ReportState {
  final ReportFilter filter;
  final Report? report;
  final bool isLoading;
  final bool isExporting;
  final String? error;
  final String? exportSuccess;

  const ReportState({
    this.filter = const ReportFilter(),
    this.report,
    this.isLoading = false,
    this.isExporting = false,
    this.error,
    this.exportSuccess,
  });

  ReportState copyWith({
    ReportFilter? filter,
    Report? report,
    bool? isLoading,
    bool? isExporting,
    String? error,
    String? exportSuccess,
    bool clearError = false,
    bool clearExportSuccess = false,
    bool clearReport = false,
  }) {
    return ReportState(
      filter: filter ?? this.filter,
      report: clearReport ? null : report ?? this.report,
      isLoading: isLoading ?? this.isLoading,
      isExporting: isExporting ?? this.isExporting,
      error: clearError ? null : error ?? this.error,
      exportSuccess: clearExportSuccess ? null : exportSuccess ?? this.exportSuccess,
    );
  }
}
