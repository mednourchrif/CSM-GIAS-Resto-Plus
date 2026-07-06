import 'package:dio/dio.dart';

import '../dto/qr_code_dto.dart';
import '../dto/qr_generate_response_dto.dart';

class QrRemoteDataSource {
  final Dio _dio;

  QrRemoteDataSource({required Dio dio}) : _dio = dio;

  Future<QrListResponse> getQrCodes({
    required int page,
    required int pageSize,
    String? search,
    String? typeFilter,
    String? statusFilter,
    String? sort,
    String? order,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
      if (search != null && search.isNotEmpty) 'search': search,
      if (typeFilter != null) 'type': typeFilter,
      if (statusFilter != null) 'status': statusFilter,
      if (sort != null) 'sort': sort,
      if (order != null) 'order': order,
    };

    final response = await _dio.get<Map<String, dynamic>>(
      '/qr',
      queryParameters: queryParams,
    );

    final body = response.data!;
    final data = (body['data'] as List<dynamic>)
        .map((e) => QrCodeDto.fromJson(e as Map<String, dynamic>))
        .toList();

    return QrListResponse(
      items: data,
      total: body['total'] as int,
      page: body['page'] as int,
      pageSize: body['page_size'] as int,
      totalPages: body['total_pages'] as int,
    );
  }

  Future<QrCodeDto> getQrCode(String uuid) async {
    final response = await _dio.get<Map<String, dynamic>>('/qr/$uuid');
    final body = response.data!;
    return QrCodeDto.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<QrGenerateResponseDto> generateInternQr(String internUuid) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/qr/generate/intern/$internUuid',
    );
    final body = response.data!;
    return QrGenerateResponseDto.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<QrGenerateResponseDto> generateVisitorQr(String visitorUuid) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/qr/generate/visitor/$visitorUuid',
    );
    final body = response.data!;
    return QrGenerateResponseDto.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<QrCodeDto> revokeQr(String uuid) async {
    final response = await _dio.post<Map<String, dynamic>>('/qr/revoke/$uuid');
    final body = response.data!;
    return QrCodeDto.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<QrGenerateResponseDto> regenerateQr(
    String ownerUuid, {
    String ownerType = 'STAGIAIRE',
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/qr/regenerate/$ownerUuid',
      queryParameters: {'owner_type': ownerType},
    );
    final body = response.data!;
    return QrGenerateResponseDto.fromJson(body['data'] as Map<String, dynamic>);
  }

  Future<List<int>> downloadQr(String uuid) async {
    final response = await _dio.get<List<int>>(
      '/qr/download/$uuid',
      options: Options(
        responseType: ResponseType.bytes,
      ),
    );
    return response.data!;
  }

  Future<List<QrCodeDto>> getQrHistory(String ownerUuid) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/qr/history/$ownerUuid',
    );
    final body = response.data!;
    final data = (body['data'] as List<dynamic>)
        .map((e) => QrCodeDto.fromJson(e as Map<String, dynamic>))
        .toList();
    return data;
  }
}

class QrListResponse {
  final List<QrCodeDto> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  const QrListResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });
}
