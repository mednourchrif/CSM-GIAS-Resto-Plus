import '../../../../../shared/models/result.dart';
import '../entities/employee.dart';

abstract class EmployeeRepository {
  Future<Result<PaginatedEmployees>> getEmployees({
    required int page,
    required int pageSize,
    String? search,
    String? sort,
    String? order,
  });

  Future<Result<Employee>> getEmployee(String uuid);

  Future<Result<Employee>> createEmployee({
    required String nom,
    required String prenom,
    required String matricule,
    String? statut,
  });

  Future<Result<Employee>> updateEmployee(
    String uuid, {
    String? nom,
    String? prenom,
    String? matricule,
    String? statut,
  });

  Future<Result<void>> deleteEmployee(String uuid);
}
