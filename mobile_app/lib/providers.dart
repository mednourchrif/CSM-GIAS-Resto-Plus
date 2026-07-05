import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

import 'core/network/api_client.dart';
import 'core/router/app_router.dart';
import 'core/storage/storage_service.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

final loggerProvider = Provider<Logger>((ref) {
  return Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 120,
      colors: true,
      printEmojis: false,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );
});

final storageServiceProvider = Provider<StorageService>((ref) {
  return SecureStorageService();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final logger = ref.watch(loggerProvider);
  return ApiClient(logger: logger);
});

final goRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ValueNotifier(0);

  ref.listen(authStateProvider, (prev, next) {
    refreshNotifier.value++;
  });

  return AppRouter.create(
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isLoginRoute = state.matchedLocation == '/login';
      final isSplashRoute = state.matchedLocation == '/splash';

      if (authState.isLoading && !isSplashRoute) return '/splash';
      if (!authState.isAuthenticated && !isLoginRoute && !isSplashRoute) {
        return '/login';
      }
      if (authState.isAuthenticated && (isLoginRoute || isSplashRoute)) {
        return '/dashboard';
      }
      return null;
    },
  );
});
