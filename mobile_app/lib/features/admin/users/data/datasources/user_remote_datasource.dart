import 'package:dio/dio.dart';

import '../dto/create_user_request_dto.dart';
import '../dto/update_user_request_dto.dart';
import '../dto/user_dto.dart';

class AdminUserRemoteDataSource {
  final Dio _dio;

  AdminUserRemoteDataSource({required Dio dio}) : _dio = dio;

  Future<UsersListResponse> getUsers({
    required int page,
    required int pageSize,
    String? search,
    String? sort,
    String? order,
    String? typeFilter,
    String? statutFilter,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
      if (search != null && search.isNotEmpty) 'search': search,
      if (sort != null) 'sort': sort,
      if (order != null) 'order': order,
      if (typeFilter != null) 'type': typeFilter,
      if (statutFilter != null) 'statut': statutFilter,
    };

    final response = await _dio.get<Map<String, dynamic>>(
      '/users',
      queryParameters: queryParams,
    );

    final body = response.data!;
    final data = (body['data'] as List<dynamic>)
        .map((e) => AdminUserDto.fromJson(e as Map<String, dynamic>))
        .toList();

    return UsersListResponse(
      items: data,
      total: body['total'] as int,
      page: body['page'] as int,
      pageSize: body['page_size'] as int,
      totalPages: body['total_pages'] as int,
    );
  }

  Future<AdminUserDto> getUser(String uuid) async {
    final response = await _dio.get<Map<String, dynamic>>('/users/$uuid');
    final body = response.data!;
    return AdminUserDto.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<AdminUserDto> createUser(CreateAdminUserRequestDto request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/users',
      data: request.toJson(),
    );
    final body = response.data!;
    return AdminUserDto.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<AdminUserDto> updateUser(
    String uuid,
    UpdateAdminUserRequestDto request,
  ) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/users/$uuid',
      data: request.toJson(),
    );
    final body = response.data!;
    return AdminUserDto.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<void> resetPassword(String uuid, String password) async {
    await _dio.put<Map<String, dynamic>>(
      '/users/$uuid/password',
      data: {'mot_de_passe': password},
    );
  }

  Future<AdminUserDto> setStatus(String uuid, String statut) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/users/$uuid/status',
      queryParameters: {'statut': statut},
    );
    final body = response.data!;
    return AdminUserDto.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<void> deleteUser(String uuid) async {
    await _dio.delete('/users/$uuid');
  }
}

class UsersListResponse {
  final List<AdminUserDto> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  const UsersListResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });
}
