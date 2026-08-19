import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../config/app_config.dart';
import 'route_names.dart';

import '../../features/admin/presentation/screens/dashboard_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/identification/domain/entities/identification_grant.dart';
import '../../features/kiosk_camera/presentation/screens/kiosk_camera_screen.dart';
import '../../features/recognition/presentation/screens/success_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

abstract final class AppRouter {
  static GlobalKey<NavigatorState> get rootNavigatorKey => _rootNavigatorKey;

  static GoRouter create({
    required String? Function(BuildContext context, GoRouterState state)
    redirect,
    required Listenable refreshListenable,
  }) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: '/splash',
      debugLogDiagnostics: AppConfig.isDevelopment,
      redirect: redirect,
      refreshListenable: refreshListenable,
      routes: [
        GoRoute(
          path: '/splash',
          name: RouteNames.splash,
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/home',
          name: RouteNames.home,
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/meal-selection',
          name: RouteNames.mealSelection,
          redirect: (context, state) {
            final extra = state.extra;
            return extra is IdentificationGrant && !extra.isExpired
                ? null
                : '/home';
          },
          builder: (context, state) {
            final extra = state.extra;
            return HomeScreen(
              initialIdentificationGrant: extra is IdentificationGrant
                  ? extra
                  : null,
            );
          },
        ),
        GoRoute(
          path: '/login',
          name: RouteNames.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/kiosk-camera',
          name: RouteNames.kioskCamera,
          builder: (context, state) => const KioskCameraScreen(),
        ),
        GoRoute(
          path: '/success',
          name: RouteNames.success,
          builder: (context, state) => const SuccessScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          name: RouteNames.dashboard,
          builder: (context, state) => const DashboardScreen(),
        ),
      ],
      errorBuilder: (context, state) => const _NotFoundPage(),
    );
  }
}

class _NotFoundPage extends StatelessWidget {
  const _NotFoundPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Page introuvable')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.wrong_location_outlined,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Cette page n’existe pas',
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Le lien est peut-être incorrect ou la page a été déplacée.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Retour à l’accueil'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
