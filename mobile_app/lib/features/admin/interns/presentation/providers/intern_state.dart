import '../../domain/entities/intern.dart';

class InternState {
  final bool isLoading;
  final List<Intern> interns;
  final Intern? selectedIntern;
  final String? error;
  final int page;
  final int totalPages;
  final int total;
  final String searchQuery;

  const InternState({
    this.isLoading = false,
    this.interns = const [],
    this.selectedIntern,
    this.error,
    this.page = 1,
    this.totalPages = 1,
    this.total = 0,
    this.searchQuery = '',
  });

  bool get hasMore => page < totalPages;

  InternState copyWith({
    bool? isLoading,
    List<Intern>? interns,
    Intern? selectedIntern,
    String? error,
    int? page,
    int? totalPages,
    int? total,
    String? searchQuery,
    bool clearError = false,
    bool clearSelected = false,
  }) {
    return InternState(
      isLoading: isLoading ?? this.isLoading,
      interns: interns ?? this.interns,
      selectedIntern:
          clearSelected ? null : (selectedIntern ?? this.selectedIntern),
      error: clearError ? null : (error ?? this.error),
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      total: total ?? this.total,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
