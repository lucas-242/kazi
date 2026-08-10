import 'package:kazi/features/settings/domain/models/billing_cycle.dart';
import 'package:kazi/features/settings/domain/models/user_settings.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

abstract class UserSettingsRepository {
  /// The user's settings, or an empty [UserSettings] when the document does not
  /// exist yet (every user predating the document).
  Future<UserSettings> get(String userId);

  Future<void> setDefaultCurrency(String userId, SupportedCurrency currency);

  Future<void> setBillingCycle(String userId, BillingCycle cycle);

  /// Marks the legacy-currency backfill as finished. Written last, so an
  /// interrupted migration is retried on the next launch.
  Future<void> markCurrencyMigrated(String userId, {required int migrated});
}
