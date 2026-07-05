import '../../domain/entities/meal_registration.dart';

class MealRegistrationState {
  final bool isLoading;
  final MealRegistration? result;
  final String? error;

  const MealRegistrationState({
    this.isLoading = false,
    this.result,
    this.error,
  });

  MealRegistrationState copyWith({
    bool? isLoading,
    MealRegistration? result,
    String? error,
    bool clearError = false,
  }) {
    return MealRegistrationState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      error: clearError ? null : (error ?? this.error),
    );
  }
}
