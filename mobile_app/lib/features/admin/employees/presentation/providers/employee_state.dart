import '../../domain/entities/employee.dart';

class EmployeeState {
  final bool isLoading;
  final List<Employee> employees;
  final Employee? selectedEmployee;
  final String? error;
  final int page;
  final int totalPages;
  final int total;
  final String searchQuery;

  const EmployeeState({
    this.isLoading = false,
    this.employees = const [],
    this.selectedEmployee,
    this.error,
    this.page = 1,
    this.totalPages = 1,
    this.total = 0,
    this.searchQuery = '',
  });

  bool get hasMore => page < totalPages;

  EmployeeState copyWith({
    bool? isLoading,
    List<Employee>? employees,
    Employee? selectedEmployee,
    String? error,
    int? page,
    int? totalPages,
    int? total,
    String? searchQuery,
    bool clearError = false,
    bool clearSelected = false,
  }) {
    return EmployeeState(
      isLoading: isLoading ?? this.isLoading,
      employees: employees ?? this.employees,
      selectedEmployee: clearSelected ? null : (selectedEmployee ?? this.selectedEmployee),
      error: clearError ? null : (error ?? this.error),
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      total: total ?? this.total,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}
