import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/home/presentation/screens/home_screen.dart';
import 'package:mobile_app/features/identification/domain/entities/identification_grant.dart';
import 'package:mobile_app/features/identification/presentation/providers/identification_provider.dart';
import 'package:mobile_app/features/meal_registration/domain/entities/meal_category.dart';
import 'package:mobile_app/features/meal_registration/presentation/providers/meal_registration_provider.dart';
import 'package:mobile_app/shared/widgets/detail_row.dart';

void main() {
  final sizes = <Size>[
    const Size(320, 568),
    const Size(568, 320),
    const Size(800, 600),
    const Size(1024, 600),
  ];

  for (final size in sizes) {
    testWidgets('kiosk has no overflow at ${size.width}x${size.height}', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));

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
        token: 'responsive-grant',
        type: 'FACE',
        expiresAt: DateTime.now().add(const Duration(minutes: 1)),
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            locale: const Locale('fr'),
            supportedLocales: const [Locale('fr')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: AppTheme.light,
            home: const HomeScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 800));

      expect(tester.takeException(), isNull);
      expect(find.text('Plat'), findsOneWidget);
      expect(find.text('Pizza'), findsOneWidget);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    });
  }

  testWidgets('detail rows stack cleanly on narrow screens', (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: DetailRow(
              label: 'Identifiant long',
              value: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
              copyable: true,
            ),
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(find.text('Identifiant long'), findsOneWidget);
  });
}
