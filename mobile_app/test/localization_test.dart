import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile_app/core/localization/app_strings.dart';
import 'package:mobile_app/features/admin/settings/domain/entities/application_settings.dart';
import 'package:mobile_app/features/home/domain/enums/meal_type.dart';

Widget _localizedHost(Locale locale) {
  return MaterialApp(
    locale: locale,
    supportedLocales: const [
      Locale('fr', 'FR'),
      Locale('en', 'US'),
      Locale('ar', 'SA'),
    ],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: Builder(
      builder: (context) {
        final strings = AppStrings.of(context);
        return Scaffold(body: Text(strings.identifyYourself));
      },
    ),
  );
}

void main() {
  testWidgets('English locale uses English strings and LTR direction', (
    tester,
  ) async {
    await tester.pumpWidget(_localizedHost(const Locale('en', 'US')));
    await tester.pumpAndSettle();

    expect(find.text('Identify yourself'), findsOneWidget);
    expect(
      tester
          .widget<Directionality>(find.byType(Directionality).first)
          .textDirection,
      TextDirection.ltr,
    );
  });

  testWidgets('Arabic locale uses Arabic strings and RTL direction', (
    tester,
  ) async {
    await tester.pumpWidget(_localizedHost(const Locale('ar', 'SA')));
    await tester.pumpAndSettle();

    expect(find.text('عرّف بنفسك'), findsOneWidget);
    expect(
      tester
          .widget<Directionality>(find.byType(Directionality).first)
          .textDirection,
      TextDirection.rtl,
    );
  });

  test('localized settings and meal labels use one locale source', () {
    const strings = AppStrings(Locale('ar', 'SA'));

    expect(strings.settingOption('en'), 'الإنجليزية');
    expect(strings.settingLabel('language', 'Langue'), 'اللغة');
    expect(strings.mealLabel(MealType.plat), 'طبق رئيسي');
  });

  test('saved language values map to supported locales', () {
    final english = ApplicationSettings.fromRawMap({'language': 'en'});
    final arabic = ApplicationSettings.fromRawMap({'language': 'ar'});
    final unsupported = ApplicationSettings.fromRawMap({'language': 'de'});

    expect(english.locale.languageCode, 'en');
    expect(arabic.locale.languageCode, 'ar');
    expect(unsupported.locale.languageCode, 'fr');
  });
}
