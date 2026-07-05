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
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final location = state.matchedLocation;

      debugPrint(
        "Router -> $location "
        "auth=${authState.isAuthenticated} "
        "loading=${authState.isLoading}",
      );

      // Always wait for splash initialisation
      if (authState.isLoading) {
        if (location != '/splash') return '/splash';
        return null;
      }

      // Splash → Home (public)
      if (location == '/splash') return '/home';

      // Dashboard requires admin authentication
      if (location.startsWith('/dashboard') && !authState.isAuthenticated) {
        return '/login';
      }

      // Authenticated on login → dashboard
      if (location == '/login' && authState.isAuthenticated) {
        return '/dashboard';
      }

      return null;
    },
  );
});
