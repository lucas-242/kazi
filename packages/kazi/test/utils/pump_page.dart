import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

import 'test_helper.dart';
import 'test_overrides.dart';

/// Renders [page] inside the same shell the real app gives it: Kazi's theme,
/// the four localization delegates from `app.dart`, and a `ProviderScope` with
/// every external dependency faked.
///
/// Returns the container so a test can read controller state after interacting.
/// The page-level widget tests override the controller they are exercising on
/// top of [TestFakes.overrides]; everything else already resolves.
Future<ProviderContainer> pumpPage(
  WidgetTester tester,
  Widget page, {
  List<Override> overrides = const [],
  TestFakes? fakes,
  Brightness brightness = Brightness.light,
  Size? surfaceSize,
}) async {
  await TestHelper.loadAppLocalizations();

  final testFakes = fakes ?? TestFakes();
  final container = ProviderContainer(
    overrides: [...testFakes.overrides, ...overrides],
  );
  addTearDown(container.dispose);
  if (fakes == null) addTearDown(testFakes.dispose);

  if (surfaceSize != null) {
    tester.view.physicalSize = surfaceSize;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: brightness == Brightness.light
            ? KaziThemeSettings.light()
            : KaziThemeSettings.dark(),
        localizationsDelegates: const [
          KaziLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: KaziLocalizations.delegate.supportedLocales,
        locale: const Locale('en'),
        home: page,
      ),
    ),
  );

  return container;
}
