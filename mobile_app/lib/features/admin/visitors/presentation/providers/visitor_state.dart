import '../../domain/entities/visitor.dart';

class VisitorState {
  final bool isLoading;
  final List<Visitor> visitors;
  final Visitor? selectedVisitor;
  final String? error;
  final int page;
  final int totalPages;
  final int total;
  final String searchQuery;

  const VisitorState({
    this.isLoading = false,
    this.visitors = const [],
    this.selectedVisitor,
    this.error,
    this.page = 1,
    this.totalPages = 1,
    this.total = 0,
    this.searchQuery = '',
  });

  bool get hasMore => page < totalPages;

  VisitorState copyWith({
    bool? isLoading,
    List<Visitor>? visitors,
    Visitor? selectedVisitor,
    String? error,
    int? page,
    int? totalPages,
    int? total,
    String? searchQuery,
    bool clearError = false,
    bool clearSelected = false,
  }) {
    return VisitorState(
      isLoading: isLoading ?? this.isLoading,
      visitors: visitors ?? this.visitors,
      selectedVisitor:
          clearSelected ? null : (selectedVisitor ?? this.selectedVisitor),
      error: clearError ? null : (error ?? this.error),
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      total: total ?? this.total,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
