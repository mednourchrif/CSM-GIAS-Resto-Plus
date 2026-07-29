import 'package:dio/dio.dart';

class FaceEnrollmentRemoteDataSource {
  final Dio _dio;

  FaceEnrollmentRemoteDataSource({required this._dio});

  Future<void> enrollFace({
    required String utilisateurUuid,
    required List<String> imagePaths,
  }) async {
    final formData = FormData.fromMap({
      'utilisateur_uuid': utilisateurUuid,
      'images': [
        for (int i = 0; i < imagePaths.length; i++)
          await MultipartFile.fromFile(imagePaths[i], filename: 'face_$i.png'),
      ],
    });

    await _dio.post(
      '/face/enroll-multiple',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 120),
      ),
    );
  }

  Future<void> deleteFace(String utilisateurUuid) async {
    await _dio.delete('/face/user/$utilisateurUuid');
  }
}
