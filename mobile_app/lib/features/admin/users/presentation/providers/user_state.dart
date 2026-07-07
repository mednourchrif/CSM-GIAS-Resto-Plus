import '../../domain/entities/user.dart';

class AdminUserState {
  final bool isLoading;
  final List<AdminUser> users;
  final AdminUser? selectedUser;
  final String? error;
  final int page;
  final int totalPages;
  final int total;
  final String searchQuery;
  final String? typeFilter;
  final String? statutFilter;
  final ({String message, bool isError})? notification;

  const AdminUserState({
    this.isLoading = false,
    this.users = const [],
    this.selectedUser,
    this.error,
    this.page = 1,
    this.totalPages = 1,
    this.total = 0,
    this.searchQuery = '',
    this.typeFilter,
    this.statutFilter,
    this.notification,
  });

  bool get hasMore => page < totalPages;

  AdminUserState copyWith({
    bool? isLoading,
    List<AdminUser>? users,
    AdminUser? selectedUser,
    String? error,
    int? page,
    int? totalPages,
    int? total,
    String? searchQuery,
    String? typeFilter,
    String? statutFilter,
    ({String message, bool isError})? notification,
    bool clearError = false,
    bool clearSelected = false,
    bool clearNotification = false,
  }) {
    return AdminUserState(
      isLoading: isLoading ?? this.isLoading,
      users: users ?? this.users,
      selectedUser: clearSelected ? null : (selectedUser ?? this.selectedUser),
      error: clearError ? null : (error ?? this.error),
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      total: total ?? this.total,
      searchQuery: searchQuery ?? this.searchQuery,
      typeFilter: typeFilter ?? this.typeFilter,
      statutFilter: statutFilter ?? this.statutFilter,
      notification: clearNotification ? null : (notification ?? this.notification),
    );
  }
}
