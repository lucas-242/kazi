import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/auth/domain/models/app_user.dart';
import 'package:kazi/features/settings/presenter/widgets/report_problem.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart';

import '../../../../../utils/fakes/fake_auth_service.dart';
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
  late _FakeUrlLauncher launcher;
  late FakeAuthService auth;

  TestHelper.loadAppLocalizations();

  setUp(() {
    launcher = _FakeUrlLauncher();
    auth = FakeAuthService(
      user: AppUser(
        uid: 'uid-1',
        name: 'Ana Banana',
        email: 'ana@test.com',
      ),
    );
  });

  tearDown(() => auth.dispose());

  Future<void> pumpAndTap(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          kaziUrlLauncherServiceProvider.overrideWithValue(launcher),
          authServiceProvider.overrideWithValue(auth),
        ],
        child: MaterialApp(
          home: Consumer(
            builder: (context, ref, _) => Scaffold(
              body: TextButton(
                onPressed: () => openProblemReport(context, ref),
                child: const Text('report'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('report'));
    await tester.pump();
  }

  testWidgets('Should open the mail app addressed to support', (tester) async {
    await pumpAndTap(tester);

    expect(
      launcher.launched.single,
      startsWith('mailto:${KaziLocalizations.current.contactEmail}?subject='),
    );
  });

  // A space encoded as `+` shows up literally in the mail app's subject line.
  testWidgets('Should encode the subject and body as percent escapes', (
    tester,
  ) async {
    await pumpAndTap(tester);

    final uri = Uri.parse(launcher.launched.single);
    final query = uri.queryParameters;

    expect(uri.query, isNot(contains('+')));
    expect(query['subject'], KaziLocalizations.current.reportProblemSubject);
    expect(query['body'], contains('Ana Banana'));
    expect(query['body'], contains('ana@test.com'));
    expect(query['body'], contains('uid-1'));
  });

  testWidgets('Should still open with a blank identity when signed out', (
    tester,
  ) async {
    auth.user = null;

    await pumpAndTap(tester);

    expect(launcher.launched, hasLength(1));
  });
}
