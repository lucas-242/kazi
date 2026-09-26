import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/services/domain/time_service.dart';
import 'package:kazi/features/clients/domain/repositories/clients_repository.dart';
import 'package:kazi/features/services/domain/repositories/services_repository.dart';
import 'package:kazi/features/subscription/domain/freemium_gate.dart';
import 'package:kazi/features/subscription/domain/freemium_guard.dart';
import 'package:kazi/features/subscription/domain/models/entitlement.dart';

import '../../../../utils/fake_subscription_service.dart';

const _newFree = Entitlement.free();
const _churned = Entitlement(
  isPremium: false,
  isInGracePeriod: false,
  willRenew: false,
  isTrial: false,
  hasPaidBefore: true,
);
const _premium = Entitlement(
  isPremium: true,
  isInGracePeriod: false,
  willRenew: true,
  isTrial: false,
  hasPaidBefore: true,
);

FreemiumGuard buildGuard({
  required Entitlement entitlement,
  int monthlyServices = 0,
  int clients = 0,
  bool reposThrow = false,
  bool isPaymentsEnabled = true,
}) {
  return FreemiumGuard(
    subscriptionService: FakeSubscriptionService(entitlement: entitlement),
    servicesRepository: _FakeServicesRepo(monthlyServices, throws: reposThrow),
    clientsRepository: _FakeClientsRepo(clients, throws: reposThrow),
    timeService: _FakeTimeService(),
    isPaymentsEnabled: isPaymentsEnabled,
  );
}

void main() {
  group('newFree', () {
    test('services allowed under limit, blocked at limit', () async {
      final under = await buildGuard(
        entitlement: _newFree,
        monthlyServices: 14,
      ).checkAddServices('u', 1);
      expect(under.isAllowed, isTrue);

      final at = await buildGuard(
        entitlement: _newFree,
        monthlyServices: 15,
      ).checkAddServices('u', 1);
      expect(at.blockedBy, LimitType.servicesPerMonth);
    });

    test('clients blocked at 5', () async {
      final blocked = await buildGuard(
        entitlement: _newFree,
        clients: 5,
      ).checkAddClient('u');
      expect(blocked.blockedBy, LimitType.clients);
    });

    test('service type uses provided in-memory count', () async {
      final guard = buildGuard(entitlement: _newFree);
      expect((await guard.checkAddCatalogItem(9)).isAllowed, isTrue);
      expect((await guard.checkAddCatalogItem(10)).isBlocked, isTrue);
    });
  });

  group('churned', () {
    test('no new types or clients, reduced service quota', () async {
      final guard = buildGuard(entitlement: _churned, monthlyServices: 5);
      expect((await guard.checkAddCatalogItem(0)).isBlocked, isTrue);
      expect((await guard.checkAddClient('u')).isBlocked, isTrue);
      expect((await guard.checkAddServices('u', 1)).isBlocked, isTrue);
    });
  });

  group('premium', () {
    test('allows everything without querying repositories', () async {
      final guard = buildGuard(entitlement: _premium, reposThrow: true);
      expect((await guard.checkAddServices('u', 99)).isAllowed, isTrue);
      expect((await guard.checkAddClient('u')).isAllowed, isTrue);
      expect((await guard.checkAddCatalogItem(99)).isAllowed, isTrue);
    });
  });

  group('payments feature flag off', () {
    test('allows everything even for a free user over every limit', () async {
      final guard = buildGuard(
        entitlement: _newFree,
        monthlyServices: 999,
        clients: 999,
        isPaymentsEnabled: false,
      );

      expect((await guard.checkAddServices('u', 99)).isAllowed, isTrue);
      expect((await guard.checkAddClient('u')).isAllowed, isTrue);
      expect((await guard.checkAddCatalogItem(99)).isAllowed, isTrue);
    });

    test('does not query repositories or the subscription', () async {
      final guard = buildGuard(
        entitlement: _churned,
        reposThrow: true,
        isPaymentsEnabled: false,
      );

      expect((await guard.checkAddServices('u', 1)).isAllowed, isTrue);
      expect((await guard.checkAddClient('u')).isAllowed, isTrue);
    });
  });
}

class _FakeServicesRepo implements ServicesRepository {
  _FakeServicesRepo(this._count, {this.throws = false});
  final int _count;
  final bool throws;

  @override
  Future<int> countCreatedSince(String userId, DateTime since) async {
    if (throws) throw StateError('should not be called for premium');
    return _count;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeClientsRepo implements ClientsRepository {
  _FakeClientsRepo(this._count, {this.throws = false});
  final int _count;
  final bool throws;

  @override
  Future<int> count(String ownerId) async {
    if (throws) throw StateError('should not be called for premium');
    return _count;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeTimeService implements TimeService {
  @override
  DateTime get now => DateTime(2026, 7, 15);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
