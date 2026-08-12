import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../providers.dart';
import '../../data/datasources/meal_remote_datasource.dart';
import '../../data/services/meal_offline_queue_service.dart';
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

final mealOfflineQueueServiceProvider = Provider<MealOfflineQueueService>((
  ref,
) {
  return MealOfflineQueueService(ref.watch(storageServiceProvider));
});

final registerMealUseCaseProvider = Provider<RegisterMealUseCase>((ref) {
  return RegisterMealUseCase(ref.watch(mealRepositoryProvider));
});

final mealRegistrationResultProvider = StateProvider<MealRegistration?>(
  (ref) => null,
);

final mealRegistrationProvider =
    StateNotifierProvider<MealRegistrationNotifier, MealRegistrationState>(
      (ref) => MealRegistrationNotifier(ref),
    );

final mealCategoriesProvider = FutureProvider<List<MealCategory>>((ref) async {
  final repository = ref.watch(mealRepositoryProvider);
  final result = await repository.getCategories();
  return result.when(
    success: (categories) => categories,
    failure: (failure) => throw StateError(failure.message),
  );
});

class MealRegistrationNotifier extends StateNotifier<MealRegistrationState> {
  final Ref _ref;
  int _operationId = 0;

  MealRegistrationNotifier(this._ref) : super(const MealRegistrationState()) {
    unawaited(refreshOfflineQueueStatus());
  }

  Future<void> refreshOfflineQueueStatus() async {
    final count = await _ref.read(mealOfflineQueueServiceProvider).count();
    if (!mounted) return;
    state = state.copyWith(offlineQueueCount: count);
  }

  Future<void> registerMeal({
    required String identificationToken,
    required String categorieUuid,
    required String mealLabel,
  }) async {
    if (state.isLoading) return;
    final operationId = ++_operationId;
    state = state.copyWith(isLoading: true, clearError: true);

    await _flushQueuedMeals();
    if (!mounted || operationId != _operationId) return;

    final useCase = _ref.read(registerMealUseCaseProvider);
    final result = await useCase(
      identificationToken: identificationToken,
      categorieUuid: categorieUuid,
    );
    if (!mounted || operationId != _operationId) return;

    result.when(
      success: (registration) {
        unawaited(refreshOfflineQueueStatus());
        _ref.read(mealRegistrationResultProvider.notifier).state = registration;
        state = MealRegistrationState(result: registration);
      },
      failure: (failure) async {
        if (failure is NetworkFailure) {
          await _ref
              .read(mealOfflineQueueServiceProvider)
              .enqueue(
                MealOfflineQueueItem(
                  identificationToken: identificationToken,
                  categorieUuid: categorieUuid,
                  mealLabel: mealLabel,
                  queuedAt: DateTime.now(),
                ),
              );
          if (!mounted || operationId != _operationId) return;
          final queueCount = await _ref
              .read(mealOfflineQueueServiceProvider)
              .count();
          if (!mounted || operationId != _operationId) return;
          final queuedRegistration = MealRegistration(
            mealLabel: mealLabel,
            registeredAt: DateTime.now(),
            identificationMethod: 'OFFLINE_QUEUE',
          );
          _ref.read(mealRegistrationResultProvider.notifier).state =
              queuedRegistration;
          state = MealRegistrationState(
            result: queuedRegistration,
            offlineQueueCount: queueCount,
            offlineNotice: 'Connexion perdue. Repas mis en file d\'attente.',
          );
          return;
        }

        state = MealRegistrationState(error: failure.message);
      },
    );
  }

  Future<void> _flushQueuedMeals() async {
    final queueService = _ref.read(mealOfflineQueueServiceProvider);
    final repository = _ref.read(mealRepositoryProvider);
    var items = await queueService.load();
    if (!mounted) return;
    var updated = false;

    while (items.isNotEmpty) {
      final item = items.first;
      final result = await repository.registerMeal(
        identificationToken: item.identificationToken,
        categorieUuid: item.categorieUuid,
      );
      if (!mounted) return;

      final shouldStop = result.when(
        success: (_) => false,
        failure: (failure) => failure is NetworkFailure,
      );

      updated = true;

      if (shouldStop) {
        break;
      }

      items = await queueService.removeFirst();
      if (!mounted) return;
    }

    if (updated) {
      await refreshOfflineQueueStatus();
    }
  }

  void reset() {
    _operationId++;
    _ref.read(mealRegistrationResultProvider.notifier).state = null;
    state = MealRegistrationState(offlineQueueCount: state.offlineQueueCount);
  }
}
