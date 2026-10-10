import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/services/domain/analytics_event.dart';
import 'package:kazi/features/settings/domain/models/billing_cycle.dart';
import 'package:kazi/features/settings/presenter/controllers/billing_cycle_controller.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

import '../utils/pump_app.dart';

/// A cycle that could not be read, standing in for Firestore failing the
/// settings read.
class _UnreadableCycleController extends BillingCycleController {
  bool _handedOut = false;

  @override
  Future<BillingCycle> build() async => BillingCycle.monthlyDefault;

  @override
  ({Object error, StackTrace trace})? takeReadFailure() {
    if (_handedOut) return null;
    _handedOut = true;
    return (error: ExternalError('offline'), trace: StackTrace.current);
  }
}

/// A cycle that could not be read falls back to the calendar month — and says
/// so, once, because a total over the wrong window otherwise looks right.
void main() {
  testWidgets('a cycle that could not be read is announced and reported', (
    tester,
  ) async {
    final app = TestAppHarness(
      overrides: [
        billingCycleControllerProvider.overrideWith(
          _UnreadableCycleController.new,
        ),
      ],
    );

    await app.pump(tester);
    await settle(tester);

    expect(
      find.text(KaziLocalizations.current.billingCycleUnavailable),
      findsOneWidget,
    );
    final shown = app.fakes.analytics.parametersOf(AnalyticsEvent.errorShown);
    expect(shown?['origin'], 'BillingCycleController');

    // Lets the snackbar's own timer run out, or the test ends with it pending.
    await tester.pump(const Duration(seconds: 7));
  });
}
