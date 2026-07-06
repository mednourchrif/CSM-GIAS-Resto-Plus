import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../providers.dart';
import '../../data/datasources/face_enrollment_remote_datasource.dart';
import '../../data/repositories/face_enrollment_repository_impl.dart';
import '../../domain/entities/face_enrollment_data.dart';
import '../../domain/repositories/face_enrollment_repository.dart';
import 'face_enrollment_state.dart';

final faceEnrollmentRemoteDataSourceProvider =
    Provider<FaceEnrollmentRemoteDataSource>((ref) {
  return FaceEnrollmentRemoteDataSource(dio: ref.watch(apiClientProvider).dio);
});

final faceEnrollmentRepositoryProvider =
    Provider<FaceEnrollmentRepository>((ref) {
  return FaceEnrollmentRepositoryImpl(
    dataSource: ref.watch(faceEnrollmentRemoteDataSourceProvider),
  );
});

final faceEnrollmentProvider =
    StateNotifierProvider<FaceEnrollmentNotifier, FaceEnrollmentState>((ref) {
  return FaceEnrollmentNotifier(ref);
});

class FaceEnrollmentNotifier extends StateNotifier<FaceEnrollmentState> {
  final Ref _ref;

  FaceEnrollmentNotifier(this._ref) : super(const FaceEnrollmentState());

  FaceEnrollmentRepository get _repo =>
      _ref.read(faceEnrollmentRepositoryProvider);

  void addImage(String filePath) {
    state = state.copyWith(
      capturedImages: [
        ...state.capturedImages,
        CapturedImage(filePath: filePath, capturedAt: DateTime.now()),
      ],
    );
  }

  void removeImage(int index) {
    final images = [...state.capturedImages];
    images.removeAt(index);
    state = state.copyWith(capturedImages: images);
  }

  void goToPreview() {
    state = state.copyWith(step: EnrollmentStep.preview);
  }

  void goToCamera() {
    state = state.copyWith(step: EnrollmentStep.camera);
  }

  Future<void> uploadImages(String utilisateurUuid) async {
    state = state.copyWith(
      step: EnrollmentStep.uploading,
      isUploading: true,
      uploadProgress: 0,
      clearError: true,
    );

    final imagePaths =
        state.capturedImages.map((img) => img.filePath).toList();

    final result = await _repo.enrollFace(
      utilisateurUuid: utilisateurUuid,
      imagePaths: imagePaths,
    );

    result.when(
      success: (data) {
        state = state.copyWith(
          step: EnrollmentStep.done,
          isUploading: false,
          uploadProgress: 1,
          result: data,
        );
      },
      failure: (failure) {
        state = state.copyWith(
          step: EnrollmentStep.error,
          isUploading: false,
          errorMessage: failure.message,
        );
      },
    );
  }

  void reset() {
    state = const FaceEnrollmentState();
  }
}
