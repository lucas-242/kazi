import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/services/domain/models/catalog_item.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi/features/services/presenter/widgets/service_card.dart';
import 'package:kazi_core/kazi_core.dart' hide Service, CatalogItem;

/// The row's pill is the only thing on the services list that names a
/// situation, so reading it off `isReceived` alone — which cannot see a
/// cancellation — colours cancelled work as money still coming.
void main() {
  final day = DateTime(2026, 8, 20);

  Service service({DateTime? receivedAt, DateTime? cancelledAt}) => Service(
    id: 'service-1',
    value: 180,
    commissionPercent: 45,
    currency: 'USD',
    rateDate: '2026-08-20',
    catalogItem: const CatalogItem(
      id: 'item-1',
      name: 'Alongamento em gel',
      userId: 'user-1',
    ),
    catalogItemId: 'item-1',
    receivedAt: receivedAt,
    cancelledAt: cancelledAt,
    date: day,
    userId: 'user-1',
  );

  Future<void> pump(WidgetTester tester, Service service) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: KaziThemeSettings.light(),
          localizationsDelegates: const [
            KaziLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: KaziLocalizations.delegate.supportedLocales,
          locale: const Locale('en'),
          home: Scaffold(
            body: ServiceCard(service: service, onTap: () {}),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  KaziStatusPill pillOf(WidgetTester tester) =>
      tester.widget<KaziStatusPill>(find.byType(KaziStatusPill));

  group('the situation pill', () {
    testWidgets('Should read a service with no stamp as pending', (
      tester,
    ) async {
      await pump(tester, service());

      expect(pillOf(tester).kind, KaziStatusPillKind.warning);
      expect(pillOf(tester).label, KaziLocalizations.current.statPending);
    });

    testWidgets('Should read a paid service as received', (tester) async {
      await pump(tester, service(receivedAt: day));

      expect(pillOf(tester).kind, KaziStatusPillKind.success);
      expect(pillOf(tester).label, KaziLocalizations.current.received);
    });

    testWidgets('Should read a cancelled service as cancelled', (tester) async {
      await pump(tester, service(cancelledAt: day));

      expect(pillOf(tester).kind, KaziStatusPillKind.danger);
      expect(pillOf(tester).label, KaziLocalizations.current.statusCancelled);
    });

    testWidgets('Should let cancellation outrank payment', (tester) async {
      await pump(tester, service(receivedAt: day, cancelledAt: day));

      expect(pillOf(tester).kind, KaziStatusPillKind.danger);
      expect(pillOf(tester).label, KaziLocalizations.current.statusCancelled);
    });
  });
}
