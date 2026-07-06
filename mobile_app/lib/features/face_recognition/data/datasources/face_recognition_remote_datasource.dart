import 'package:dio/dio.dart';

import '../../../../core/network/api_response.dart';
import '../dto/face_identify_request_dto.dart';
import '../dto/face_identify_response_dto.dart';

class FaceRecognitionRemoteDataSource {
  final Dio _dio;

  FaceRecognitionRemoteDataSource({required Dio dio}) : _dio = dio;

  Future<FaceIdentifyResponseDto> identify({
    required String imageBase64,
    String? categorieUuid,
  }) async {
    final request = FaceIdentifyRequestDto(
      imageBase64: imageBase64,
      categorieUuid: categorieUuid,
    );

    final response = await _dio.post<Map<String, dynamic>>(
      '/face/identify',
      data: request.toJson(),
    );

    final apiResponse =
        ApiResponse<Map<String, dynamic>>.fromResponse(response);
    return FaceIdentifyResponseDto.fromJson(apiResponse.data ?? {});
  }
}
