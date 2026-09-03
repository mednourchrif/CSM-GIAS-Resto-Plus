import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../providers.dart';
import '../../../receipts/domain/entities/receipt.dart';
import '../../data/datasources/meal_remote_datasource.dart';
import '../../data/repositories/meal_repository_impl.dart';
import '../../data/services/meal_offline_queue_service.dart';
import '../../data/services/meal_sync_service.dart';
import '../../data/services/offline_manifest_service.dart';
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

final offlineManifestServiceProvider = Provider<OfflineManifestService>((ref) {
  return OfflineManifestService(ref.watch(storageServiceProvider));
});

final mealSyncServiceProvider = Provider<MealSyncService>((ref) {
  final service = MealSyncService(
    dio: ref.watch(apiClientProvider).dio,
    queueService: ref.watch(mealOfflineQueueServiceProvider),
    manifestService: ref.watch(offlineManifestServiceProvider),
    onQueueCountChanged: (count) {
      ref.read(mealRegistrationProvider.notifier).updateOfflineCount(count);
    },
  );
  service.startPeriodicSync();
  ref.onDispose(() => service.stopPeriodicSync());
  return service;
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
  final manifest = ref.watch(offlineManifestServiceProvider);

  final result = await repository.getCategories();
  return result.when(
    success: (categories) {
      unawaited(manifest.cacheCategories(categories));
      return categories;
    },
    failure: (_) async {
      // Return cached categories or default fallback if offline
      return await manifest.getCachedCategories();
    },
  );
});

class MealRegistrationNotifier extends StateNotifier<MealRegistrationState> {
  final Ref _ref;
  int _operationId = 0;

  MealRegistrationNotifier(this._ref) : super(const MealRegistrationState()) {
    unawaited(refreshOfflineQueueStatus());
    // Eagerly initialize sync service so background sync starts immediately
    _ref.read(mealSyncServiceProvider);
  }

  void updateOfflineCount(int count) {
    if (!mounted) return;
    state = state.copyWith(offlineQueueCount: count);
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

    // If this is an offline grant, bypass backend API and queue locally
    if (identificationToken.startsWith('OFFLINE_')) {
      final qrToken = identificationToken.substring(8);
      await _registerMealOffline(
        qrToken: qrToken,
        categorieUuid: categorieUuid,
        mealLabel: mealLabel,
        operationId: operationId,
      );
      return;
    }

    // Try flushing queued meals when online
    unawaited(_ref.read(mealSyncServiceProvider).syncNow());

    final useCase = _ref.read(registerMealUseCaseProvider);
    final result = await useCase(
      identificationToken: identificationToken,
      categorieUuid: categorieUuid,
    );
    if (!mounted || operationId != _operationId) return;

    await result.when(
      success: (registration) async {
        unawaited(refreshOfflineQueueStatus());
        _ref.read(mealRegistrationResultProvider.notifier).state = registration;
        state = MealRegistrationState(result: registration);
      },
      failure: (failure) async {
        if (failure is NetworkFailure) {
          await _registerMealOffline(
            qrToken: identificationToken,
            categorieUuid: categorieUuid,
            mealLabel: mealLabel,
            operationId: operationId,
          );
          return;
        }

        state = MealRegistrationState(error: failure.message);
      },
    );
  }

  Future<void> _registerMealOffline({
    required String qrToken,
    required String categorieUuid,
    required String mealLabel,
    required int operationId,
  }) async {
    final now = DateTime.now();
    final randomSuffix = Random().nextInt(999999).toString().padLeft(6, '0');
    final offlineId = 'OFF-${now.millisecondsSinceEpoch}-$randomSuffix';
    final dateStr = DateFormat('yyyyMMdd').format(now);
    final receiptNumber = 'RCP-OFF-$dateStr-$randomSuffix';

    final manifestService = _ref.read(offlineManifestServiceProvider);
    final cachedUser = await manifestService.findUserByQrToken(qrToken);

    final receipt = Receipt(
      uuid: offlineId,
      number: receiptNumber,
      mealUuid: offlineId,
      userUuid: cachedUser?.userUuid ?? 'offline-$randomSuffix',
      firstName: cachedUser?.prenom ?? 'Employé',
      lastName: cachedUser?.nom ?? '',
      employeeNumber: cachedUser?.matricule,
      userType: cachedUser?.type ?? 'EMPLOYE',
      categoryUuid: categorieUuid,
      categoryName: mealLabel,
      identificationType: 'QR (Hors-ligne)',
      mealDate: DateTime(now.year, now.month, now.day),
      servedAt: now,
      qrToken: qrToken,
    );

    final queueItem = MealOfflineQueueItem(
      offlineId: offlineId,
      qrToken: qrToken,
      identificationToken: qrToken,
      categorieUuid: categorieUuid,
      mealLabel: mealLabel,
      registeredAt: now,
      userName: cachedUser?.fullName,
      userMatricule: cachedUser?.matricule,
      receiptNumber: receiptNumber,
    );

    await _ref.read(mealOfflineQueueServiceProvider).enqueue(queueItem);
    await manifestService.recordLocalMealToday(qrToken);

    if (!mounted || operationId != _operationId) return;
    final queueCount = await _ref.read(mealOfflineQueueServiceProvider).count();
    if (!mounted || operationId != _operationId) return;

    final queuedRegistration = MealRegistration(
      userName: cachedUser?.fullName,
      mealLabel: mealLabel,
      registeredAt: now,
      identificationMethod: 'OFFLINE_QUEUE',
      receipt: receipt,
    );

    _ref.read(mealRegistrationResultProvider.notifier).state = queuedRegistration;
    state = MealRegistrationState(
      result: queuedRegistration,
      offlineQueueCount: queueCount,
      offlineNotice: 'Connexion réseau absente. Repas enregistré et stocké localement.',
    );
  }

  void reset() {
    _operationId++;
    _ref.read(mealRegistrationResultProvider.notifier).state = null;
    state = MealRegistrationState(offlineQueueCount: state.offlineQueueCount);
  }
}
