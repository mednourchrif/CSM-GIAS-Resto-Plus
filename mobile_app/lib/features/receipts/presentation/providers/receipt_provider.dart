import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers.dart';
import '../../domain/entities/receipt.dart';

class ReceiptState {
  final List<Receipt> receipts;
  final bool isLoading;
  final String? error;
  final int page;
  final int totalPages;
  final int total;
  final String search;
  final DateTime? dateFrom;
  final DateTime? dateTo;
  final String? category;
  final String? userType;
  final String? identificationType;

  const ReceiptState({
    this.receipts = const [],
    this.isLoading = false,
    this.error,
    this.page = 1,
    this.totalPages = 1,
    this.total = 0,
    this.search = '',
    this.dateFrom,
    this.dateTo,
    this.category,
    this.userType,
    this.identificationType,
  });

  ReceiptState copyWith({
    List<Receipt>? receipts,
    bool? isLoading,
    String? error,
    bool clearError = false,
    int? page,
    int? totalPages,
    int? total,
    String? search,
    DateTime? dateFrom,
    DateTime? dateTo,
    bool clearDates = false,
    String? category,
    bool clearCategory = false,
    String? userType,
    bool clearUserType = false,
    String? identificationType,
    bool clearIdentificationType = false,
  }) => ReceiptState(
    receipts: receipts ?? this.receipts,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : error ?? this.error,
    page: page ?? this.page,
    totalPages: totalPages ?? this.totalPages,
    total: total ?? this.total,
    search: search ?? this.search,
    dateFrom: clearDates ? null : dateFrom ?? this.dateFrom,
    dateTo: clearDates ? null : dateTo ?? this.dateTo,
    category: clearCategory ? null : category ?? this.category,
    userType: clearUserType ? null : userType ?? this.userType,
    identificationType: clearIdentificationType
        ? null
        : identificationType ?? this.identificationType,
  );
}

final receiptProvider = StateNotifierProvider<ReceiptNotifier, ReceiptState>((
  ref,
) {
  return ReceiptNotifier(ref.watch(apiClientProvider).dio);
});

class ReceiptNotifier extends StateNotifier<ReceiptState> {
  final Dio _dio;
  int _requestVersion = 0;

  ReceiptNotifier(this._dio) : super(const ReceiptState());

  Future<void> load({int? page}) async {
    final version = ++_requestVersion;
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      page: page ?? state.page,
    );
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/receipts',
        queryParameters: {
          'page': state.page,
          'page_size': 20,
          if (state.search.isNotEmpty) 'search': state.search,
          if (state.dateFrom != null)
            'date_from': state.dateFrom!.toIso8601String().split('T').first,
          if (state.dateTo != null)
            'date_to': state.dateTo!.toIso8601String().split('T').first,
          if (state.category != null) 'category': state.category,
          if (state.userType != null) 'user_type': state.userType,
          if (state.identificationType != null)
            'identification_type': state.identificationType,
        },
      );
      if (version != _requestVersion) return;
      final body = response.data!;
      state = state.copyWith(
        isLoading: false,
        receipts: (body['data'] as List<dynamic>)
            .map((item) => Receipt.fromJson(item as Map<String, dynamic>))
            .toList(),
        total: body['total'] as int? ?? 0,
        totalPages: body['total_pages'] as int? ?? 1,
        page: body['page'] as int? ?? 1,
      );
    } on DioException catch (error) {
      if (version != _requestVersion) return;
      final body = error.response?.data;
      state = state.copyWith(
        isLoading: false,
        error: body is Map<String, dynamic>
            ? body['message'] as String? ?? 'Impossible de charger les reçus.'
            : 'Impossible de charger les reçus.',
      );
    }
  }

  Future<void> setSearch(String value) async {
    state = state.copyWith(search: value, page: 1);
    await load();
  }

  Future<void> setFilters({
    DateTime? dateFrom,
    DateTime? dateTo,
    String? category,
    String? userType,
    String? identificationType,
  }) async {
    state = state.copyWith(
      dateFrom: dateFrom,
      dateTo: dateTo,
      clearDates: dateFrom == null && dateTo == null,
      category: category,
      clearCategory: category == null,
      userType: userType,
      clearUserType: userType == null,
      identificationType: identificationType,
      clearIdentificationType: identificationType == null,
      page: 1,
    );
    await load();
  }

  Future<void> resetFilters() async {
    state = ReceiptState(search: state.search);
    await load();
  }
}
