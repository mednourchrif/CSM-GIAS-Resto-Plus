import 'package:dio/dio.dart';

import '../../../../core/network/api_response.dart';
import '../dto/face_identify_request_dto.dart';
import '../dto/face_identify_response_dto.dart';

class FaceRecognitionRemoteDataSource {
  final Dio _dio;

  FaceRecognitionRemoteDataSource({required this._dio});

  Future<FaceIdentifyResponseDto> identify({
    required String imageBase64,
  }) async {
    final request = FaceIdentifyRequestDto(imageBase64: imageBase64);

    final response = await _dio.post<Map<String, dynamic>>(
      '/face/identify',
      data: request.toJson(),
    );

    final apiResponse = ApiResponse<Map<String, dynamic>>.fromResponse(
      response,
    );
    return FaceIdentifyResponseDto.fromJson(apiResponse.data ?? {});
  }
}
