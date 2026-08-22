import 'package:kazi/core/services/domain/time_service.dart';
import 'package:kazi/features/clients/domain/repositories/clients_repository.dart';
import 'package:kazi/features/services/domain/repositories/services_repository.dart';
import 'package:kazi/features/subscription/domain/freemium_gate.dart';
import 'package:kazi/features/subscription/domain/models/user_tier.dart';
import 'package:kazi/features/subscription/domain/services/subscription_service.dart';

class FreemiumGuard {
  FreemiumGuard({
    required SubscriptionService subscriptionService,
    required ServicesRepository servicesRepository,
    required ClientsRepository clientsRepository,
    required TimeService timeService,
    this.isPaymentsEnabled = true,
  }) : _subscriptionService = subscriptionService,
       _servicesRepository = servicesRepository,
       _clientsRepository = clientsRepository,
       _timeService = timeService;

  final SubscriptionService _subscriptionService;
  final ServicesRepository _servicesRepository;
  final ClientsRepository _clientsRepository;
  final TimeService _timeService;

  /// Whether the paid tier exists at all (`FeatureFlag.payments`). With payments
  /// off there is nothing to upgrade to, so no limit may block a creation.
  final bool isPaymentsEnabled;

  Future<UserTier> _currentTier() async =>
      (await _subscriptionService.current()).tier;

  DateTime get _startOfMonth {
    final now = _timeService.now;
    return DateTime(now.year, now.month);
  }

  /// Whether the user can create [quantity] more services this month.
  Future<GateResult> checkAddServices(String userId, int quantity) async {
    if (!isPaymentsEnabled) {
      return const GateResult.allowed();
    }
    final gate = FreemiumGate(await _currentTier());
    if (gate.tier == UserTier.premium) {
      return const GateResult.allowed();
    }
    final count = await _servicesRepository.countCreatedSince(
      userId,
      _startOfMonth,
    );
    return gate.canAddServices(count, quantity);
  }

  /// Whether the user can create another catalog item. [currentItemCount] is the
  /// number the user already has (usually the in-memory list length).
  Future<GateResult> checkAddCatalogItem(int currentItemCount) async {
    if (!isPaymentsEnabled) {
      return const GateResult.allowed();
    }
    final gate = FreemiumGate(await _currentTier());
    return gate.canAddCatalogItem(currentItemCount);
  }

  /// Whether the user can create another client.
  Future<GateResult> checkAddClient(String ownerId) async {
    if (!isPaymentsEnabled) {
      return const GateResult.allowed();
    }
    final gate = FreemiumGate(await _currentTier());
    if (gate.tier == UserTier.premium) {
      return const GateResult.allowed();
    }
    final count = await _clientsRepository.count(ownerId);
    return gate.canAddClient(count);
  }
}
