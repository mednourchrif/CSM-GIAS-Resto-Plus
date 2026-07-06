import 'package:dio/dio.dart';

import '../dto/create_employee_request_dto.dart';
import '../dto/employee_dto.dart';
import '../dto/update_employee_request_dto.dart';

class EmployeeRemoteDataSource {
  final Dio _dio;

  EmployeeRemoteDataSource({required Dio dio}) : _dio = dio;

  Future<EmployeesListResponse> getEmployees({
    required int page,
    required int pageSize,
    String? search,
    String? sort,
    String? order,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
      if (search != null && search.isNotEmpty) 'search': search,
      if (sort != null) 'sort': sort,
      if (order != null) 'order': order,
    };

    final response = await _dio.get<Map<String, dynamic>>(
      '/employees',
      queryParameters: queryParams,
    );

    final body = response.data!;
    final data = (body['data'] as List<dynamic>)
        .map((e) => EmployeeDto.fromJson(e as Map<String, dynamic>))
        .toList();

    return EmployeesListResponse(
      items: data,
      total: body['total'] as int,
      page: body['page'] as int,
      pageSize: body['page_size'] as int,
      totalPages: body['total_pages'] as int,
    );
  }

  Future<EmployeeDto> getEmployee(String uuid) async {
    final response = await _dio.get<Map<String, dynamic>>('/employees/$uuid');
    final body = response.data!;
    return EmployeeDto.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<EmployeeDto> createEmployee(CreateEmployeeRequestDto request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/employees',
      data: request.toJson(),
    );
    final body = response.data!;
    return EmployeeDto.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<EmployeeDto> updateEmployee(
    String uuid,
    UpdateEmployeeRequestDto request,
  ) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/employees/$uuid',
      data: request.toJson(),
    );
    final body = response.data!;
    return EmployeeDto.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<void> deleteEmployee(String uuid) async {
    await _dio.delete('/employees/$uuid');
  }
}

class EmployeesListResponse {
  final List<EmployeeDto> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  const EmployeesListResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });
}
