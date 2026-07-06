import '../../domain/entities/qr_code.dart';

class QrState {
  final bool isLoading;
  final List<QrCode> qrCodes;
  final QrCode? selectedQrCode;
  final String? error;
  final int page;
  final int totalPages;
  final int total;
  final String searchQuery;
  final String? typeFilter;
  final String? statusFilter;

  const QrState({
    this.isLoading = false,
    this.qrCodes = const [],
    this.selectedQrCode,
    this.error,
    this.page = 1,
    this.totalPages = 1,
    this.total = 0,
    this.searchQuery = '',
    this.typeFilter,
    this.statusFilter,
  });

  bool get hasMore => page < totalPages;

  QrState copyWith({
    bool? isLoading,
    List<QrCode>? qrCodes,
    QrCode? selectedQrCode,
    String? error,
    int? page,
    int? totalPages,
    int? total,
    String? searchQuery,
    String? typeFilter,
    String? statusFilter,
    bool clearError = false,
    bool clearSelected = false,
  }) {
    return QrState(
      isLoading: isLoading ?? this.isLoading,
      qrCodes: qrCodes ?? this.qrCodes,
      selectedQrCode:
          clearSelected ? null : (selectedQrCode ?? this.selectedQrCode),
      error: clearError ? null : (error ?? this.error),
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      total: total ?? this.total,
      searchQuery: searchQuery ?? this.searchQuery,
      typeFilter: typeFilter ?? this.typeFilter,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}
