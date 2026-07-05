import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';

import '../../features/admin/presentation/screens/dashboard_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/identification/presentation/screens/identification_method_screen.dart';
import '../../features/meal_registration/presentation/screens/qr_scanner_screen.dart';
import '../../features/recognition/presentation/screens/face_placeholder_screen.dart';
import '../../features/recognition/presentation/screens/processing_screen.dart';
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
      debugLogDiagnostics: true,
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
          path: '/login',
          name: RouteNames.login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/identification-method',
          name: RouteNames.identificationMethod,
          builder: (context, state) => const IdentificationMethodScreen(),
        ),
        GoRoute(
          path: '/face',
          name: RouteNames.face,
          builder: (context, state) => const FacePlaceholderScreen(),
        ),
        GoRoute(
          path: '/qr',
          name: RouteNames.qr,
          builder: (context, state) => const QrScannerScreen(),
        ),
        GoRoute(
          path: '/processing',
          name: RouteNames.processing,
          builder: (context, state) => const ProcessingScreen(),
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
      errorBuilder: (context, state) => const _PlaceholderPage(title: '404'),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;

  const _PlaceholderPage({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction_rounded,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(
              'This page is under construction.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
