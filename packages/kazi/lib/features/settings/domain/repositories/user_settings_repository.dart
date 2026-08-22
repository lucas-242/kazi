import 'package:kazi/features/settings/domain/models/billing_cycle.dart';
import 'package:kazi/features/settings/domain/models/user_settings.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

abstract class UserSettingsRepository {
  /// The user's settings, or an empty [UserSettings] when the document does not
  /// exist yet (every user predating the document).
  Future<UserSettings> get(String userId);

  Future<void> setDefaultCurrency(String userId, SupportedCurrency currency);

  Future<void> setBillingCycle(String userId, BillingCycle cycle);

  /// Marks the legacy-currency backfill as finished. Written last, so an
  /// interrupted migration is retried on the next launch.
  Future<void> markCurrencyMigrated(String userId, {required int migrated});

  /// Records the profession chosen (or typed) in the first setup step, so an
  /// interrupted run does not lose the answer.
  Future<void> setProfession(String userId, String profession);

  /// Stamps the guided setup as finished. Written after every other setup
  /// write, so a failure midway leaves the setup pending rather than losing
  /// the user's catalog.
  Future<void> markSetupCompleted(String userId);

  /// Records that the user left the setup through the close button.
  Future<void> markSetupSkipped(String userId);

  /// Marks one home-checklist step whose completion is not derivable from the
  /// user's own data.
  Future<void> markOnboardingStep(String userId, String step);

  /// Debug only: clears every onboarding stamp so the guided setup can be run
  /// again on the same account. The user's catalog and services are left
  /// alone, which is why a reset alone does not re-seed anything.
  Future<void> resetOnboardingForDebug(String userId);
}
