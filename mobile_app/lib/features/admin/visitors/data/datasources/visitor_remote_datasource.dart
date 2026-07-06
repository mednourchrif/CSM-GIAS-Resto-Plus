import 'package:dio/dio.dart';

import '../dto/create_visitor_request_dto.dart';
import '../dto/update_visitor_request_dto.dart';
import '../dto/visitor_dto.dart';

class VisitorRemoteDataSource {
  final Dio _dio;

  VisitorRemoteDataSource({required Dio dio}) : _dio = dio;

  Future<VisitorsListResponse> getVisitors({
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
      '/visitors',
      queryParameters: queryParams,
    );

    final body = response.data!;
    final data = (body['data'] as List<dynamic>)
        .map((e) => VisitorDto.fromJson(e as Map<String, dynamic>))
        .toList();

    return VisitorsListResponse(
      items: data,
      total: body['total'] as int,
      page: body['page'] as int,
      pageSize: body['page_size'] as int,
      totalPages: body['total_pages'] as int,
    );
  }

  Future<VisitorDto> getVisitor(String uuid) async {
    final response = await _dio.get<Map<String, dynamic>>('/visitors/$uuid');
    final body = response.data!;
    return VisitorDto.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<VisitorDto> createVisitor(CreateVisitorRequestDto request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/visitors',
      data: request.toJson(),
    );
    final body = response.data!;
    return VisitorDto.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<VisitorDto> updateVisitor(
    String uuid,
    UpdateVisitorRequestDto request,
  ) async {
    final response = await _dio.put<Map<String, dynamic>>(
      '/visitors/$uuid',
      data: request.toJson(),
    );
    final body = response.data!;
    return VisitorDto.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<void> deleteVisitor(String uuid) async {
    await _dio.delete<Map<String, dynamic>>('/visitors/$uuid');
  }
}

class VisitorsListResponse {
  final List<VisitorDto> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  const VisitorsListResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });
}
