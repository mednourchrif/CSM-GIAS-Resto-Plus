import 'package:dio/dio.dart';

import '../../../../core/network/api_response.dart';
import '../dto/identification_grant_dto.dart';

class IdentificationRemoteDataSource {
  final Dio _dio;

  IdentificationRemoteDataSource({required this._dio});

  Future<IdentificationGrantDto> identifyByQr(String qrToken) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/identification/qr',
      data: {'token': qrToken},
    );
    final apiResponse = ApiResponse<Map<String, dynamic>>.fromResponse(
      response,
    );
    final data = apiResponse.data;
    if (data == null) {
      throw const FormatException('Missing identification response data.');
    }
    return IdentificationGrantDto.fromJson(data);
  }
}
