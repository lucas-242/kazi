import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/dashboard/presenter/controllers/dashboard_state.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi_core/kazi_core.dart' hide Service;

void main() {
  // 1 USD = 5 BRL in the frozen snapshot.
  const snapshot = {'USD': 1.0, 'BRL': 5.0};

  Service service({required double value, required String currency}) => Service(
        value: value,
        currency: currency,
        rates: snapshot,
        userId: 'user-1',
      );

  group('DashboardState totals with mixed currencies', () {
    test('converts each service to the default currency before summing', () {
      final state = DashboardState(
        status: BaseStateStatus.success,
        defaultCurrency: SupportedCurrency.brl,
        services: [
          service(value: 20, currency: 'USD'), // 20 USD -> 100 BRL
          service(value: 50, currency: 'BRL'), // 50 BRL
        ],
      );

      expect(state.totalValue, 150);
    });

    test('legacy services without a snapshot are summed as-is', () {
      final state = DashboardState(
        status: BaseStateStatus.success,
        defaultCurrency: SupportedCurrency.brl,
        services: [
          Service(value: 20, userId: 'user-1'),
          Service(value: 50, userId: 'user-1'),
        ],
      );

      expect(state.totalValue, 70);
    });
  });
}
