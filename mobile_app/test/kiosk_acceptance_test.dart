import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/features/auth/data/datasources/auth_interceptor.dart';
import 'package:mobile_app/features/home/domain/enums/meal_type.dart';
import 'package:mobile_app/features/home/presentation/providers/selection_providers.dart';
import 'package:mobile_app/features/home/presentation/screens/home_screen.dart';
import 'package:mobile_app/features/identification/data/datasources/identification_remote_datasource.dart';
import 'package:mobile_app/features/identification/data/repositories/identification_repository_impl.dart';
import 'package:mobile_app/features/identification/domain/entities/identification_grant.dart';
import 'package:mobile_app/features/identification/presentation/providers/identification_provider.dart';
import 'package:mobile_app/features/identification/presentation/providers/kiosk_flow_provider.dart';
import 'package:mobile_app/features/meal_registration/data/datasources/meal_remote_datasource.dart';
import 'package:mobile_app/features/meal_registration/data/repositories/meal_repository_impl.dart';
import 'package:mobile_app/features/meal_registration/domain/entities/meal_category.dart';
import 'package:mobile_app/features/meal_registration/domain/entities/meal_registration.dart';
import 'package:mobile_app/features/meal_registration/domain/repositories/meal_repository.dart';
import 'package:mobile_app/features/meal_registration/domain/usecases/register_meal_usecase.dart';
import 'package:mobile_app/features/meal_registration/presentation/providers/meal_registration_provider.dart';
import 'package:mobile_app/shared/models/result.dart';

void main() {
  group('kiosk transient-state acceptance', () {
    test('reset clears grants, selections, result, and submission lock', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container
          .read(pendingIdentificationProvider.notifier)
          .state = IdentificationGrant(
        token: 'temporary-token',
        type: 'QR',
        expiresAt: DateTime.now().add(const Duration(minutes: 1)),
      );
      container.read(selectedMealProvider.notifier).state = MealType.plat;
      container.read(selectedCategoryUuidProvider.notifier).state = 'category';
      container
          .read(mealRegistrationResultProvider.notifier)
          .state = MealRegistration(
        mealLabel: 'Plat',
        registeredAt: DateTime.now(),
        identificationMethod: 'QR',
      );
      container.read(kioskSubmissionLockedProvider.notifier).state = true;

      container.read(resetKioskFlowProvider)();

      expect(container.read(pendingIdentificationProvider), isNull);
      expect(container.read(selectedMealProvider), isNull);
      expect(container.read(selectedCategoryUuidProvider), isNull);
      expect(container.read(mealRegistrationResultProvider), isNull);
      expect(container.read(kioskSubmissionLockedProvider), isFalse);
    });

    test('meal selection reset preserves a new identification grant', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final grant = IdentificationGrant(
        token: 'fresh-face-token',
        type: 'FACE',
        expiresAt: DateTime.now().add(const Duration(minutes: 1)),
      );
      container.read(selectedMealProvider.notifier).state = MealType.plat;
      container.read(selectedCategoryUuidProvider.notifier).state = 'old-cat';
      container
          .read(mealRegistrationResultProvider.notifier)
          .state = MealRegistration(
        mealLabel: 'Plat',
        registeredAt: DateTime.now(),
        identificationMethod: 'FACE',
      );
      container.read(kioskSubmissionLockedProvider.notifier).state = true;

      container.read(resetKioskMealSelectionProvider)();
      container.read(pendingIdentificationProvider.notifier).state = grant;

      expect(container.read(pendingIdentificationProvider), same(grant));
      expect(container.read(selectedMealProvider), isNull);
      expect(container.read(selectedCategoryUuidProvider), isNull);
      expect(container.read(mealRegistrationResultProvider), isNull);
      expect(container.read(kioskSubmissionLockedProvider), isFalse);
    });

    testWidgets('identified users see meal categories on home screen', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          mealCategoriesProvider.overrideWith(
            (ref) async => const [
              MealCategory(uuid: 'plat', nom: 'Plat'),
              MealCategory(uuid: 'pizza', nom: 'Pizza'),
              MealCategory(uuid: 'sandwich', nom: 'Sandwich'),
            ],
          ),
        ],
      );
      addTearDown(container.dispose);
      container
          .read(pendingIdentificationProvider.notifier)
          .state = IdentificationGrant(
        token: 'face-token',
        type: 'FACE',
        expiresAt: DateTime.now().add(const Duration(minutes: 1)),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            locale: Locale('fr'),
            supportedLocales: [Locale('fr')],
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Identifiez-vous'), findsNothing);
      expect(find.text('Plat'), findsOneWidget);
      expect(find.text('Pizza'), findsOneWidget);
      expect(find.text('Sandwich'), findsWidgets);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });

    testWidgets('home route extra can carry an identification grant', (
      tester,
    ) async {
      final grant = IdentificationGrant(
        token: 'route-face-token',
        type: 'FACE',
        expiresAt: DateTime.now().add(const Duration(minutes: 1)),
      );
      final container = ProviderContainer(
        overrides: [
          mealCategoriesProvider.overrideWith(
            (ref) async => const [MealCategory(uuid: 'plat', nom: 'Plat')],
          ),
        ],
      );
      addTearDown(container.dispose);
      final router = GoRouter(
        initialLocation: '/camera',
        routes: [
          GoRoute(
            path: '/camera',
            builder: (context, state) => Scaffold(
              body: FilledButton(
                onPressed: () => context.go('/home', extra: grant),
                child: const Text('identified'),
              ),
            ),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) {
              final extra = state.extra;
              return HomeScreen(
                initialIdentificationGrant: extra is IdentificationGrant
                    ? extra
                    : null,
              );
            },
          ),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('identified'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      expect(container.read(pendingIdentificationProvider), same(grant));
      expect(find.text('Identifiez-vous'), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });

    test('a new provider container starts with no kiosk identity', () {
      final first = ProviderContainer();
      first
          .read(pendingIdentificationProvider.notifier)
          .state = IdentificationGrant(
        token: 'in-memory-only',
        type: 'QR',
        expiresAt: DateTime.now().add(const Duration(minutes: 1)),
      );
      first.dispose();

      final restarted = ProviderContainer();
      addTearDown(restarted.dispose);
      expect(restarted.read(pendingIdentificationProvider), isNull);
    });

    testWidgets('backgrounding the home flow clears temporary identity', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          mealCategoriesProvider.overrideWith(
            (ref) async => const [MealCategory(uuid: 'plat', nom: 'Plat')],
          ),
        ],
      );
      addTearDown(container.dispose);
      container
          .read(pendingIdentificationProvider.notifier)
          .state = IdentificationGrant(
        token: 'background-token',
        type: 'QR',
        expiresAt: DateTime.now().add(const Duration(minutes: 1)),
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            locale: Locale('fr'),
            supportedLocales: [Locale('fr')],
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pump();

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pump();

      expect(container.read(pendingIdentificationProvider), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });

    testWidgets('cancelling confirmation returns the kiosk to idle', (
      tester,
    ) async {
      final container = ProviderContainer(
        overrides: [
          mealCategoriesProvider.overrideWith(
            (ref) async => const [MealCategory(uuid: 'plat', nom: 'Plat')],
          ),
        ],
      );
      addTearDown(container.dispose);
      container
          .read(pendingIdentificationProvider.notifier)
          .state = IdentificationGrant(
        token: 'cancel-token',
        type: 'QR',
        expiresAt: DateTime.now().add(const Duration(minutes: 1)),
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            locale: Locale('fr'),
            supportedLocales: [Locale('fr')],
            localizationsDelegates: [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: HomeScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      await tester.tap(find.text('Plat'));
      await tester.pump(const Duration(milliseconds: 500));
      await tester.tap(find.text('Annuler'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(container.read(pendingIdentificationProvider), isNull);
      expect(container.read(kioskSubmissionLockedProvider), isFalse);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });
  });

  group('submission and network acceptance', () {
    test('registration notifier rejects concurrent submissions', () async {
      final repository = _SlowMealRepository();
      final container = ProviderContainer(
        overrides: [
          registerMealUseCaseProvider.overrideWithValue(
            RegisterMealUseCase(repository),
          ),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(mealRegistrationProvider.notifier);

      final first = notifier.registerMeal(
        identificationToken: 'grant',
        categorieUuid: 'category',
        mealLabel: 'Plat',
      );
      final second = notifier.registerMeal(
        identificationToken: 'grant',
        categorieUuid: 'category',
        mealLabel: 'Plat',
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));
      expect(repository.calls, 1);

      repository.complete();
      await Future.wait([first, second]);
      expect(container.read(mealRegistrationProvider).result, isNotNull);
    });

    test('reset ignores a late network response', () async {
      final repository = _SlowMealRepository();
      final container = ProviderContainer(
        overrides: [
          registerMealUseCaseProvider.overrideWithValue(
            RegisterMealUseCase(repository),
          ),
        ],
      );
      addTearDown(container.dispose);
      final notifier = container.read(mealRegistrationProvider.notifier);

      final pending = notifier.registerMeal(
        identificationToken: 'grant',
        categorieUuid: 'category',
        mealLabel: 'Plat',
      );
      notifier.reset();
      repository.complete();
      await pending;

      expect(container.read(mealRegistrationProvider).result, isNull);
      expect(container.read(mealRegistrationResultProvider), isNull);
    });

    test('identification and registration convert network failures', () async {
      final dio = Dio()..httpClientAdapter = _FailingAdapter();
      final identification = IdentificationRepositoryImpl(
        remoteDataSource: IdentificationRemoteDataSource(dio: dio),
      );
      final meals = MealRepositoryImpl(
        remoteDataSource: MealRemoteDataSource(dio: dio),
      );

      expect(
        await identification.identifyByQr('x' * 32),
        isA<Fail<IdentificationGrant>>(),
      );
      expect(
        await meals.registerMeal(
          identificationToken: 'x' * 32,
          categorieUuid: 'category',
        ),
        isA<Fail<MealRegistration>>(),
      );
    });

    test('kiosk 401 does not clear an unrelated admin session', () async {
      var unauthorizedCallbacks = 0;
      final kioskDio = Dio()
        ..httpClientAdapter = _UnauthorizedAdapter()
        ..interceptors.add(
          AuthInterceptor(onUnauthorized: () => unauthorizedCallbacks++),
        );

      await expectLater(
        kioskDio.post<void>('/meals/register'),
        throwsA(isA<DioException>()),
      );
      expect(unauthorizedCallbacks, 0);

      final adminDio = Dio()
        ..httpClientAdapter = _UnauthorizedAdapter()
        ..interceptors.add(
          AuthInterceptor(
            initialToken: 'admin-token',
            onUnauthorized: () => unauthorizedCallbacks++,
          ),
        );
      await expectLater(
        adminDio.get<void>('/users'),
        throwsA(isA<DioException>()),
      );
      expect(unauthorizedCallbacks, 1);
    });
  });
}

class _SlowMealRepository implements MealRepository {
  final Completer<Result<MealRegistration>> _completer = Completer();
  int calls = 0;

  @override
  Future<Result<MealRegistration>> registerMeal({
    required String identificationToken,
    required String categorieUuid,
  }) {
    calls++;
    return _completer.future;
  }

  void complete() {
    _completer.complete(
      Success(
        MealRegistration(
          mealLabel: 'Plat',
          registeredAt: DateTime.now(),
          identificationMethod: 'QR',
        ),
      ),
    );
  }

  @override
  Future<Result<List<MealCategory>>> getCategories() async => const Success([]);
}

class _FailingAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) {
    throw DioException(
      requestOptions: options,
      type: DioExceptionType.connectionError,
      error: 'offline',
    );
  }

  @override
  void close({bool force = false}) {}
}

class _UnauthorizedAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '{"message":"unauthorized"}',
      401,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
