import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/clients/presenter/widgets/contact_options_sheet.dart';
import 'package:kazi_core/kazi_core.dart';

import '../../../../../utils/test_helper.dart';

class _FakeUrlLauncher implements KaziUrlLauncherService {
  final List<String> launched = [];

  @override
  Future<bool> launch(String url) async {
    launched.add(url);
    return true;
  }
}

void main() {
  const phone = '+55 (11) 98888-7777';

  late _FakeUrlLauncher launcher;
  late List<String> copied;

  TestHelper.loadAppLocalizations();

  setUp(() {
    launcher = _FakeUrlLauncher();
    copied = [];

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            copied.add((call.arguments as Map)['text'] as String);
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  Future<void> openSheet(WidgetTester tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            body: Consumer(
              builder: (context, ref, _) => TextButton(
                onPressed: () => openContactOptions(context, ref, phone),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ],
    );
    KaziNavigator.init(router);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [kaziUrlLauncherServiceProvider.overrideWithValue(launcher)],
        child: MaterialApp.router(
          theme: KaziThemeSettings.light(),
          routerConfig: router,
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('Should copy the number as it was saved', (tester) async {
    await openSheet(tester);

    await tester.tap(find.text(KaziLocalizations.current.copyNumber));
    await tester.pumpAndSettle();

    expect(copied, [phone]);
    expect(launcher.launched, isEmpty);
    expect(find.text(KaziLocalizations.current.numberCopied), findsOneWidget);

    // The snackbar dismisses itself on a timer the test has to outlive.
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('Should dial the digits alone', (tester) async {
    await openSheet(tester);

    await tester.tap(find.text(KaziLocalizations.current.call));
    await tester.pumpAndSettle();

    expect(launcher.launched, ['tel:+5511988887777']);
    expect(copied, isEmpty);
  });
}
