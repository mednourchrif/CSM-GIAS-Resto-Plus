import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../providers.dart';
import '../../data/datasources/meal_remote_datasource.dart';
import '../../data/repositories/meal_repository_impl.dart';
import '../../domain/entities/meal_category.dart';
import '../../domain/entities/meal_registration.dart';
import '../../domain/repositories/meal_repository.dart';
import '../../domain/usecases/register_meal_usecase.dart';
import 'meal_registration_state.dart';

final mealRemoteDataSourceProvider = Provider<MealRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return MealRemoteDataSource(dio: apiClient.dio);
});

final mealRepositoryProvider = Provider<MealRepository>((ref) {
  return MealRepositoryImpl(
    remoteDataSource: ref.watch(mealRemoteDataSourceProvider),
  );
});

final registerMealUseCaseProvider = Provider<RegisterMealUseCase>((ref) {
  return RegisterMealUseCase(ref.watch(mealRepositoryProvider));
});

final mealRegistrationResultProvider =
    StateProvider<MealRegistration?>((ref) => null);

final mealRegistrationProvider =
    StateNotifierProvider<MealRegistrationNotifier, MealRegistrationState>(
  (ref) => MealRegistrationNotifier(ref),
);

final mealCategoriesProvider = FutureProvider<List<MealCategory>>((ref) async {
  final repository = ref.watch(mealRepositoryProvider);
  final result = await repository.getCategories();
  return result.when(
    success: (categories) => categories,
    failure: (_) => <MealCategory>[],
  );
});

class MealRegistrationNotifier extends StateNotifier<MealRegistrationState> {
  final Ref _ref;

  MealRegistrationNotifier(this._ref) : super(const MealRegistrationState());

  Future<void> registerMeal({
    required String qrToken,
    required String categorieUuid,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final useCase = _ref.read(registerMealUseCaseProvider);
    final result = await useCase(qrToken: qrToken, categorieUuid: categorieUuid);

    result.when(
      success: (registration) {
        _ref.read(mealRegistrationResultProvider.notifier).state = registration;
        state = MealRegistrationState(result: registration);
      },
      failure: (failure) {
        state = MealRegistrationState(error: failure.message);
      },
    );
  }

  void reset() {
    _ref.read(mealRegistrationResultProvider.notifier).state = null;
    state = const MealRegistrationState();
  }
}
