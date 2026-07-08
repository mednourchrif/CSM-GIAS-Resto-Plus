import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../providers.dart';
import '../../data/datasources/employee_remote_datasource.dart';
import '../../data/repositories/employee_repository_impl.dart';
import '../../domain/entities/employee.dart';
import '../../domain/entities/employee_detail.dart';
import '../../domain/repositories/employee_repository.dart';
import 'employee_state.dart';

final employeeRemoteDataSourceProvider = Provider<EmployeeRemoteDataSource>((ref) {
  return EmployeeRemoteDataSource(dio: ref.watch(apiClientProvider).dio);
});

final employeeRepositoryProvider = Provider<EmployeeRepository>((ref) {
  return EmployeeRepositoryImpl(
    dataSource: ref.watch(employeeRemoteDataSourceProvider),
  );
});

final employeeProvider =
    StateNotifierProvider<EmployeeNotifier, EmployeeState>((ref) {
  return EmployeeNotifier(ref);
});

class EmployeeNotifier extends StateNotifier<EmployeeState> {
  final Ref _ref;
  int _refreshVersion = 0;

  EmployeeNotifier(this._ref) : super(const EmployeeState());

  EmployeeRepository get _repo =>
      _ref.read(employeeRepositoryProvider);

  Future<void> loadEmployees({bool refresh = false}) async {
    if (!refresh && state.isLoading) return;

    final loadPage = refresh ? 1 : state.page;
    final version = ++_refreshVersion;

    state = state.copyWith(
      isLoading: true,
      clearError: true,
      page: loadPage,
      employees: refresh ? [] : state.employees,
    );

    final result = await _repo.getEmployees(
      page: loadPage,
      pageSize: 20,
      search: state.searchQuery.isNotEmpty ? state.searchQuery : null,
    );

    if (version != _refreshVersion) return;

    result.when(
      success: (paginated) {
        state = state.copyWith(
          isLoading: false,
          employees: refresh
              ? paginated.items
              : [...state.employees, ...paginated.items],
          total: paginated.total,
          totalPages: paginated.totalPages,
          page: paginated.page,
        );
      },
      failure: (failure) {
        state = state.copyWith(
          isLoading: false,
          employees: refresh ? [] : state.employees,
          error: failure.message,
        );
      },
    );
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(page: state.page + 1);
    await loadEmployees();
  }

  Future<void> search(String query) async {
    state = state.copyWith(searchQuery: query, page: 1);
    await loadEmployees(refresh: true);
  }

  Future<void> refresh() async {
    await loadEmployees(refresh: true);
  }

  Future<Employee?> getEmployee(String uuid) async {
    final result = await _repo.getEmployee(uuid);
    return result.when(
      success: (employee) {
        state = state.copyWith(selectedEmployee: employee);
        return employee;
      },
      failure: (failure) {
        state = state.copyWith(error: failure.message);
        return null;
      },
    );
  }

  Future<bool> createEmployee({
    required String nom,
    required String prenom,
    required String matricule,
    String? statut,
  }) async {
    final result = await _repo.createEmployee(
      nom: nom,
      prenom: prenom,
      matricule: matricule,
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

  Future<bool> updateEmployee(
    String uuid, {
    String? nom,
    String? prenom,
    String? matricule,
    String? statut,
  }) async {
    final result = await _repo.updateEmployee(
      uuid,
      nom: nom,
      prenom: prenom,
      matricule: matricule,
      statut: statut,
    );

    return result.when(
      success: (employee) {
        state = state.copyWith(selectedEmployee: employee);
        refresh();
        return true;
      },
      failure: (failure) {
        state = state.copyWith(error: failure.message);
        return false;
      },
    );
  }

  Future<bool> deleteEmployee(String uuid) async {
    final result = await _repo.deleteEmployee(uuid);

    return result.when(
      success: (_) {
        state = state.copyWith(
          selectedEmployee: null,
          clearSelected: true,
          employees: state.employees.where((e) => e.uuid != uuid).toList(),
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

final employeeDetailProvider =
    FutureProvider.family<EmployeeDetail, String>((ref, uuid) async {
  final repo = ref.read(employeeRepositoryProvider);
  final result = await repo.getEmployeeDetail(uuid);
  return result.when(
    success: (detail) => detail,
    failure: (failure) => throw Exception(failure.message),
  );
});
