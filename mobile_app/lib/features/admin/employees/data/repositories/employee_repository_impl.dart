import 'package:dio/dio.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../shared/models/result.dart';
import '../../../../../shared/utils/dio_error_mapper.dart';
import '../../domain/entities/employee.dart';
import '../../domain/entities/employee_detail.dart';
import '../../domain/repositories/employee_repository.dart';
import '../datasources/employee_remote_datasource.dart';
import '../dto/create_employee_request_dto.dart';
import '../dto/update_employee_request_dto.dart';

class EmployeeRepositoryImpl implements EmployeeRepository {
  final EmployeeRemoteDataSource _dataSource;

  EmployeeRepositoryImpl({required EmployeeRemoteDataSource dataSource})
      : _dataSource = dataSource;

  @override
  Future<Result<PaginatedEmployees>> getEmployees({
    required int page,
    required int pageSize,
    String? search,
    String? sort,
    String? order,
  }) async {
    try {
      final response = await _dataSource.getEmployees(
        page: page,
        pageSize: pageSize,
        search: search,
        sort: sort,
        order: order,
      );
      return Success(PaginatedEmployees(
        items: response.items.map((e) => e.toDomain()).toList(),
        total: response.total,
        page: response.page,
        pageSize: response.pageSize,
        totalPages: response.totalPages,
      ));
    } on DioException catch (e) {
      return Fail(mapDioError(e, resourceName: 'employé'));
    } catch (e) {
      return Fail(ApiFailure(message: 'Erreur lors du chargement des employés.'));
    }
  }

  @override
  Future<Result<Employee>> getEmployee(String uuid) async {
    try {
      final dto = await _dataSource.getEmployee(uuid);
      return Success(dto.toDomain());
    } on DioException catch (e) {
      return Fail(mapDioError(e, resourceName: 'employé'));
    } catch (e) {
      return Fail(ApiFailure(message: 'Erreur lors du chargement de l\'employé.'));
    }
  }

  @override
  Future<Result<EmployeeDetail>> getEmployeeDetail(String uuid) async {
    try {
      final dto = await _dataSource.getEmployeeDetail(uuid);
      return Success(dto.toDomain());
    } on DioException catch (e) {
      return Fail(mapDioError(e, resourceName: 'employé'));
    } catch (e) {
      return Fail(ApiFailure(message: 'Erreur lors du chargement des détails.'));
    }
  }

  @override
  Future<Result<Employee>> createEmployee({
    required String nom,
    required String prenom,
    required String matricule,
    String? statut,
  }) async {
    try {
      final request = CreateEmployeeRequestDto(
        nom: nom,
        prenom: prenom,
        matricule: matricule,
        statut: statut,
      );
      final dto = await _dataSource.createEmployee(request);
      return Success(dto.toDomain());
    } on DioException catch (e) {
      return Fail(mapDioError(e, resourceName: 'employé'));
    } catch (e) {
      return Fail(ApiFailure(message: 'Erreur lors de la création de l\'employé.'));
    }
  }

  @override
  Future<Result<Employee>> updateEmployee(
    String uuid, {
    String? nom,
    String? prenom,
    String? matricule,
    String? statut,
  }) async {
    try {
      final request = UpdateEmployeeRequestDto(
        nom: nom,
        prenom: prenom,
        matricule: matricule,
        statut: statut,
      );
      final dto = await _dataSource.updateEmployee(uuid, request);
      return Success(dto.toDomain());
    } on DioException catch (e) {
      return Fail(mapDioError(e, resourceName: 'employé'));
    } catch (e) {
      return Fail(ApiFailure(message: 'Erreur lors de la modification de l\'employé.'));
    }
  }

  @override
  Future<Result<void>> deleteEmployee(String uuid) async {
    try {
      await _dataSource.deleteEmployee(uuid);
      return const Success(null);
    } on DioException catch (e) {
      return Fail(mapDioError(e, resourceName: 'employé'));
    } catch (e) {
      return Fail(ApiFailure(message: 'Erreur lors de la suppression de l\'employé.'));
    }
  }
}
