import '../../domain/entities/meal_registration.dart';

class MealRegistrationState {
  final bool isLoading;
  final MealRegistration? result;
  final String? error;
  final int offlineQueueCount;
  final String? offlineNotice;

  const MealRegistrationState({
    this.isLoading = false,
    this.result,
    this.error,
    this.offlineQueueCount = 0,
    this.offlineNotice,
  });

  MealRegistrationState copyWith({
    bool? isLoading,
    MealRegistration? result,
    String? error,
    bool clearError = false,
    int? offlineQueueCount,
    String? offlineNotice,
    bool clearOfflineNotice = false,
  }) {
    return MealRegistrationState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      error: clearError ? null : (error ?? this.error),
      offlineQueueCount: offlineQueueCount ?? this.offlineQueueCount,
      offlineNotice: clearOfflineNotice
          ? null
          : (offlineNotice ?? this.offlineNotice),
    );
  }
}
