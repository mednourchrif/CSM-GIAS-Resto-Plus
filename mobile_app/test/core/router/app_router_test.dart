import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/core/router/app_router.dart';

void main() {
  Set<String> routePaths(GoRouter router) => router.configuration.routes
      .whereType<GoRoute>()
      .map((route) => route.path)
      .toSet();

  GoRouter createRouter({required bool webAdminOnly}) => AppRouter.create(
    webAdminOnly: webAdminOnly,
    refreshListenable: ValueNotifier<int>(0),
    redirect: (_, _) => null,
  );

  test('Web router exposes only authentication and administration', () {
    final router = createRouter(webAdminOnly: true);
    addTearDown(router.dispose);

    expect(routePaths(router), {'/splash', '/login', '/dashboard'});
  });

  test('Android router retains the complete kiosk journey', () {
    final router = createRouter(webAdminOnly: false);
    addTearDown(router.dispose);

    expect(
      routePaths(router),
      containsAll({'/home', '/meal-selection', '/kiosk-camera', '/success'}),
    );
  });
}
