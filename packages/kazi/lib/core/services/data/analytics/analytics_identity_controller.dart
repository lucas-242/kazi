import 'dart:async';

import 'package:kazi/core/environment/environment.dart';
import 'package:kazi/core/services/domain/analytics_service.dart';
import 'package:kazi/features/auth/domain/models/app_user.dart';
import 'package:kazi/features/onboarding/presenter/controllers/onboarding_controller.dart';
import 'package:kazi/features/settings/presenter/controllers/billing_cycle_controller.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

part 'analytics_identity_controller.g.dart';

/// Keeps the analytics identity and its cohort attributes in sync with the app.
///
/// These properties are what turn a funnel into a comparison: without them it
/// says *that* people dropped out, with them it says *which*. Both sinks get the
/// Firebase uid as `distinctId`, so a PostHog funnel and a Firebase audience
/// describe the same person.
@Riverpod(keepAlive: true)
class AnalyticsIdentityController extends _$AnalyticsIdentityController {
  AnalyticsService get _analytics => ref.read(analyticsServiceProvider);

  @override
  Future<void> build() async {
    final isPremium = ref.watch(isPremiumProvider);
    final segment = ref.watch(onboardingControllerProvider).asData?.value;
    final currency = ref.watch(kaziDefaultCurrencyProvider);
    final cycle = ref.watch(billingCycleProvider);
    final paymentsEnabled = ref.watch(isPaymentsEnabledProvider);

    // Watched for the rebuild, not the boolean: this stream's `map` is what
    // assigns `authService.user` (see `KaziFirebaseAuthService`), so
    // subscribing is what guarantees the uid below is current.
    final authenticated = ref.watch(kaziIsAuthenticatedProvider).asData?.value;
    final user = ref.watch(authServiceProvider).user;

    if (authenticated != true || user == null) {
      await _analytics.reset();
      return;
    }

    final properties = <String, Object>{
      'is_premium': isPremium,
      'tier': isPremium ? 'premium' : 'free',
      'default_currency': currency.name,
      'billing_cycle': cycle.type.name,
      'payments_enabled': paymentsEnabled,
      'flavor': Environment.instance.flavor.value,
      if (segment != null) 'onboarding_segment': segment.name,
      if (await _appVersion() case final String version)
        'app_version': version,
      if (_accountAgeDays(user) case final int days) 'account_age_days': days,
    };

    await _analytics.identify(user.uid, properties: properties);

    // Last and unawaited: these are Firestore reads, and the identity is more
    // useful arriving now than arriving complete.
    unawaited(_reportCounts(user.uid));
  }

  /// Bucketed, never exact: a bucket answers any breakdown a funnel can ask,
  /// while an exact count describes an individual's business.
  Future<void> _reportCounts(String userId) async {
    try {
      final services = await ref.read(servicesRepositoryProvider).count(userId);
      final clients = await ref.read(clientsRepositoryProvider).count(userId);
      final types = await ref.read(serviceTypeRepositoryProvider).get(userId);

      await _analytics.setUserProperties({
        'services_bucket': _bucket(services),
        'clients_bucket': _bucket(clients),
        'service_types_count': types.length,
      });
    } catch (exception) {
      Log.error(exception);
    }
  }

  /// Null rather than a guess: a missing version drops one breakdown, a wrong
  /// one puts a release's users in another release's cohort.
  Future<String?> _appVersion() async {
    try {
      return await ref.read(kaziAppInfoServiceProvider).getVersion();
    } catch (exception) {
      Log.error(exception);
      return null;
    }
  }

  static int? _accountAgeDays(AppUser user) {
    final createdAt = user.createdAt;
    if (createdAt == null) return null;
    return DateTime.now().difference(createdAt).inDays;
  }

  static String _bucket(int count) => switch (count) {
    0 => '0',
    1 => '1',
    < 5 => '2-4',
    < 10 => '5-9',
    < 25 => '10-24',
    < 50 => '25-49',
    < 100 => '50-99',
    _ => '100+',
  };
}
