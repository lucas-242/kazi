import 'package:kazi/core/services/domain/time_service.dart';
import 'package:kazi/features/clients/domain/repositories/clients_repository.dart';
import 'package:kazi/features/services/domain/repositories/services_repository.dart';
import 'package:kazi/features/subscription/domain/freemium_guard.dart';
import 'package:kazi/features/subscription/domain/models/entitlement.dart';
import 'package:kazi/features/subscription/domain/services/subscription_service.dart';

class FakeSubscriptionService implements SubscriptionService {
  FakeSubscriptionService({
    this.entitlement = const Entitlement(
      isPremium: true,
      isInGracePeriod: false,
      willRenew: true,
      isTrial: false,
      hasPaidBefore: true,
    ),
    this.trialEligible = false,
    this.price = r'R$ 4,90',
  });

  final Entitlement entitlement;
  final bool trialEligible;
  final String? price;

  @override
  Future<void> configure(String? appUserId) async {}

  @override
  Future<void> logIn(String appUserId) async {}

  @override
  Future<void> logOut() async {}

  @override
  Future<Entitlement> current() async => entitlement;

  @override
  Stream<Entitlement> changes() => Stream.value(entitlement);

  @override
  Future<bool> isTrialEligible() async => trialEligible;

  @override
  Future<String?> monthlyPriceString() async => price;

  @override
  Future<Entitlement> purchaseMonthly() async => entitlement;

  @override
  Future<Entitlement> restore() async => entitlement;
}

/// Builds a [FreemiumGuard] backed entirely by fakes (no Firebase), for
/// overriding `freemiumGuardProvider` in controller tests. Defaults to premium
/// so every action is allowed.
FreemiumGuard fakeFreemiumGuard({
  Entitlement entitlement = const Entitlement(
    isPremium: true,
    isInGracePeriod: false,
    willRenew: true,
    isTrial: false,
    hasPaidBefore: true,
  ),
  int monthlyServices = 0,
  int clients = 0,
}) {
  return FreemiumGuard(
    subscriptionService: FakeSubscriptionService(entitlement: entitlement),
    servicesRepository: _NoopServicesRepository(monthlyServices),
    clientsRepository: _NoopClientsRepository(clients),
    timeService: _NoopTimeService(),
  );
}

class _NoopServicesRepository implements ServicesRepository {
  _NoopServicesRepository(this._count);
  final int _count;

  @override
  Future<int> countCreatedSince(String userId, DateTime since) async => _count;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoopClientsRepository implements ClientsRepository {
  _NoopClientsRepository(this._count);
  final int _count;

  @override
  Future<int> count(String ownerId) async => _count;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _NoopTimeService implements TimeService {
  @override
  DateTime get now => DateTime(2026, 7, 15);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
