import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/dashboard/presenter/controllers/dashboard_state.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi_core/kazi_core.dart' hide Service;

void main() {
  final today = DateTime(2026, 8, 8, 15, 30);

  Service service({required DateTime date, double value = 100}) => Service(
    value: value,
    discountPercent: 55,
    date: date,
    userId: 'user-1',
  );

  DashboardState state({
    required List<Service> services,
    DateTime? referenceDate,
  }) => DashboardState(
    status: BaseStateStatus.success,
    defaultCurrency: SupportedCurrency.brl,
    services: services,
    referenceDate: referenceDate,
  );

  group('todayServices', () {
    test('keeps only the services of the reference day', () {
      final result = state(
        referenceDate: today,
        services: [
          service(date: DateTime(2026, 8, 8, 9)),
          service(date: DateTime(2026, 8, 8, 23, 59)),
          service(date: DateTime(2026, 8, 7)),
          service(date: DateTime(2026, 8, 31)),
        ],
      ).todayServices;

      expect(result.length, 2);
      expect(result.every((s) => s.date.day == 8), isTrue);
    });

    test('is empty before the first fetch sets a reference date', () {
      expect(state(services: [service(date: today)]).todayServices, isEmpty);
    });
  });

  group('sharePercent', () {
    test('is the share the user keeps, not the discount', () {
      final result = state(
        referenceDate: today,
        services: [service(date: today), service(date: DateTime(2026, 8, 2))],
      );

      expect(result.totals.value, 200);
      expect(result.sharePercent, 45);
    });

    test('is null when there is no gross to divide by', () {
      expect(state(referenceDate: today, services: []).sharePercent, isNull);
    });
  });
}
