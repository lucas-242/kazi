import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/subscription/domain/freemium_gate.dart';
import 'package:kazi/features/subscription/domain/models/user_tier.dart';

void main() {
  group('newFree tier', () {
    final gate = FreemiumGate(UserTier.newFree);

    test('service types blocked at 3', () {
      expect(gate.canAddServiceType(2).isAllowed, isTrue);
      final blocked = gate.canAddServiceType(3);
      expect(blocked.isBlocked, isTrue);
      expect(blocked.blockedBy, LimitType.serviceType);
    });

    test('clients blocked at 5', () {
      expect(gate.canAddClient(4).isAllowed, isTrue);
      expect(gate.canAddClient(5).isBlocked, isTrue);
      expect(gate.canAddClient(5).blockedBy, LimitType.clients);
    });

    test('services blocked when month total would exceed 15', () {
      expect(gate.canAddServices(14, 1).isAllowed, isTrue);
      expect(gate.canAddServices(15, 1).isBlocked, isTrue);
      // Batch quantity counts against the limit.
      expect(gate.canAddServices(10, 5).isAllowed, isTrue);
      expect(gate.canAddServices(10, 6).isBlocked, isTrue);
      expect(
        gate.canAddServices(0, 16).blockedBy,
        LimitType.servicesPerMonth,
      );
    });
  });

  group('churned tier', () {
    final gate = FreemiumGate(UserTier.churned);

    test('cannot add any new service type or client', () {
      expect(gate.canAddServiceType(0).isBlocked, isTrue);
      expect(gate.canAddClient(0).isBlocked, isTrue);
    });

    test('reduced monthly service quota of 5', () {
      expect(gate.canAddServices(4, 1).isAllowed, isTrue);
      expect(gate.canAddServices(5, 1).isBlocked, isTrue);
    });
  });

  group('premium tier', () {
    final gate = FreemiumGate(UserTier.premium);

    test('never blocks', () {
      expect(gate.canAddServiceType(999).isAllowed, isTrue);
      expect(gate.canAddClient(999).isAllowed, isTrue);
      expect(gate.canAddServices(999, 999).isAllowed, isTrue);
    });
  });
}
