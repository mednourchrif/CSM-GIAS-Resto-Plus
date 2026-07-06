import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers.dart';
import '../../data/datasources/face_recognition_remote_datasource.dart';
import '../../data/repositories/face_recognition_repository_impl.dart';
import '../../domain/entities/face_recognition_result.dart';
import '../../domain/repositories/face_recognition_repository.dart';
import '../../domain/usecases/identify_face_usecase.dart';
import 'face_recognition_state.dart';

final faceRecognitionRemoteDataSourceProvider =
    Provider<FaceRecognitionRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FaceRecognitionRemoteDataSource(dio: apiClient.dio);
});

final faceRecognitionRepositoryProvider =
    Provider<FaceRecognitionRepository>((ref) {
  return FaceRecognitionRepositoryImpl(
    remoteDataSource: ref.watch(faceRecognitionRemoteDataSourceProvider),
  );
});

final identifyFaceUseCaseProvider = Provider<IdentifyFaceUseCase>((ref) {
  return IdentifyFaceUseCase(ref.watch(faceRecognitionRepositoryProvider));
});

final faceRecognitionProvider =
    StateNotifierProvider<FaceRecognitionNotifier, FaceRecognitionState>(
  (ref) => FaceRecognitionNotifier(ref),
);

class FaceRecognitionNotifier extends StateNotifier<FaceRecognitionState> {
  final Ref _ref;

  FaceRecognitionNotifier(this._ref) : super(const FaceRecognitionState());

  Future<FaceRecognitionResult?> identify({
    required String imageBase64,
    String? categorieUuid,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final useCase = _ref.read(identifyFaceUseCaseProvider);
    final result = await useCase(
      imageBase64: imageBase64,
      categorieUuid: categorieUuid,
    );

    FaceRecognitionResult? faceResult;
    result.when(
      success: (data) {
        faceResult = data;
        state = FaceRecognitionState(result: data);
      },
      failure: (failure) {
        state = FaceRecognitionState(error: failure.message);
      },
    );
    return faceResult;
  }

  void reset() {
    state = const FaceRecognitionState();
  }
}
