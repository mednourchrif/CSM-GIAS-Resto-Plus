import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'core/router/app_router.dart';
import 'core/storage/storage_service.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

final loggerProvider = Provider<Logger>((ref) {
  return Logger(printer: PrettyPrinter(methodCount: 0, errorMethodCount: 5));
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
    webAdminOnly: AppConfig.isWebAdmin,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final location = state.matchedLocation;

      // Always wait for splash initialisation
      if (authState.isLoading) {
        if (location != '/splash') return '/splash';
        return null;
      }

      // Select the platform's authenticated or public landing screen.
      if (AppConfig.isWebAdmin) {
        if (location == '/splash') {
          return authState.isAuthenticated ? '/dashboard' : '/login';
        }

        // Only authenticated administration is exposed in a browser. The
        // public kiosk journey and its shared tablet key remain Android-only.
        final isWebRoute =
            location == '/login' || location.startsWith('/dashboard');
        if (!isWebRoute) {
          return authState.isAuthenticated ? '/dashboard' : '/login';
        }
      } else if (location == '/splash') {
        return '/home';
      }

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
