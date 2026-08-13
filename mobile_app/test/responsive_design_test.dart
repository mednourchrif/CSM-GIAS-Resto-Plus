import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';
import 'package:mobile_app/core/theme/app_theme.dart';
import 'package:mobile_app/features/home/presentation/screens/home_screen.dart';
import 'package:mobile_app/features/identification/domain/entities/identification_grant.dart';
import 'package:mobile_app/features/identification/presentation/providers/identification_provider.dart';
import 'package:mobile_app/features/meal_registration/domain/entities/meal_category.dart';
import 'package:mobile_app/features/meal_registration/presentation/providers/meal_registration_provider.dart';
import 'package:mobile_app/shared/widgets/detail_row.dart';
import 'package:mobile_app/features/admin/presentation/widgets/admin_navigation_rail.dart';
import 'package:mobile_app/features/admin/employees/presentation/screens/employee_form_screen.dart';
import 'package:mobile_app/features/receipts/domain/entities/receipt.dart';
import 'package:mobile_app/features/receipts/presentation/providers/receipt_provider.dart';
import 'package:mobile_app/features/receipts/presentation/screens/receipt_list_screen.dart';

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

  for (final size in <Size>[
    const Size(800, 480),
    const Size(1024, 600),
    const Size(1280, 720),
  ]) {
    testWidgets(
      'admin rail scrolls without overflow at ${size.width}x${size.height}',
      (tester) async {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          MaterialApp(
            locale: const Locale('fr'),
            supportedLocales: const [Locale('fr')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: AppTheme.light,
            home: Scaffold(
              body: Row(
                children: [
                  AdminNavigationRail(
                    selectedIndex: 0,
                    extended: size.width >= 1200,
                    onDestinationSelected: (_) {},
                  ),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final size in <Size>[const Size(320, 568), const Size(568, 320)]) {
    testWidgets(
      'employee form has no overflow at ${size.width}x${size.height}',
      (tester) async {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              theme: AppTheme.light,
              home: const Scaffold(body: EmployeeFormScreen()),
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final size in <Size>[const Size(320, 568), const Size(568, 320)]) {
    testWidgets(
      'receipt history has no overflow at ${size.width}x${size.height}',
      (tester) async {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              receiptProvider.overrideWith((ref) => _TestReceiptNotifier()),
            ],
            child: MaterialApp(
              theme: AppTheme.light,
              home: const ReceiptListScreen(),
            ),
          ),
        );
        await tester.pump();
        expect(tester.takeException(), isNull);
        expect(find.text('Journal des reçus'), findsOneWidget);
      },
    );
  }
}

class _TestReceiptNotifier extends ReceiptNotifier {
  _TestReceiptNotifier() : super(Dio()) {
    state = ReceiptState(
      total: 1,
      receipts: [
        Receipt(
          uuid: 'receipt-1',
          number: 'RCP-20260812-ABCDEF',
          mealUuid: 'meal-1',
          userUuid: 'user-1',
          firstName: 'Jean',
          lastName: 'Employé avec un nom très long',
          employeeNumber: 'EMP-2026-0001',
          userType: 'EMPLOYE',
          categoryUuid: 'category-1',
          categoryName: 'Plat',
          identificationType: 'QR',
          mealDate: DateTime(2026, 8, 12),
          servedAt: DateTime(2026, 8, 12, 13, 10),
        ),
      ],
    );
  }

  @override
  Future<void> load({int? page}) async {}
}
