import 'package:dio/dio.dart';

import '../dto/create_intern_request_dto.dart';
import '../dto/intern_dto.dart';
import '../dto/update_intern_request_dto.dart';

class InternRemoteDataSource {
  final Dio _dio;

  InternRemoteDataSource({required Dio dio}) : _dio = dio;

  Future<InternsListResponse> getInterns({
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
      '/interns',
      queryParameters: queryParams,
    );

    final body = response.data!;
    final data = (body['data'] as List<dynamic>)
        .map((e) => InternDto.fromJson(e as Map<String, dynamic>))
        .toList();

    return InternsListResponse(
      items: data,
      total: body['total'] as int,
      page: body['page'] as int,
      pageSize: body['page_size'] as int,
      totalPages: body['total_pages'] as int,
    );
  }

  Future<InternDto> getIntern(String uuid) async {
    final response = await _dio.get<Map<String, dynamic>>('/interns/$uuid');
    final body = response.data!;
    return InternDto.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<InternDto> createIntern(CreateInternRequestDto request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/interns',
      data: request.toJson(),
    );
    final body = response.data!;
    return InternDto.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<InternDto> updateIntern(
    String uuid,
    UpdateInternRequestDto request,
  ) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/interns/$uuid',
      data: request.toJson(),
    );
    final body = response.data!;
    return InternDto.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<void> deleteIntern(String uuid) async {
    await _dio.delete<Map<String, dynamic>>('/interns/$uuid');
  }
}

class InternsListResponse {
  final List<InternDto> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  const InternsListResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });
}
