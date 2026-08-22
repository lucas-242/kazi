import 'package:equatable/equatable.dart';
import 'package:kazi/features/settings/domain/models/billing_cycle.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// The user's account-level preferences, stored on `users/{uid}`.
///
/// This is the authoritative home for the default currency: local storage is
/// wiped on sign-out, so a device-local copy alone would silently reinterpret
/// every stored amount after a re-login. The billing cycle rides along for the
/// same reason — a returning user reading their earnings over the wrong window
/// is the same class of error.
class UserSettings extends Equatable {
  const UserSettings({
    this.defaultCurrency,
    this.currencyMigratedAt,
    this.migratedServices = 0,
    this.billingCycle = BillingCycle.monthlyDefault,
    this.setupCompletedAt,
    this.setupSkippedAt,
    this.profession,
    this.completedOnboardingSteps = const {},
    this.hasExplicitBillingCycle = false,
  });

  /// Null when the user has never chosen one — the signal that the currency
  /// migration still has to ask.
  final SupportedCurrency? defaultCurrency;

  /// When the legacy-currency backfill finished. Null means it still has to
  /// run, which is what makes the migration resumable after a crash.
  final DateTime? currencyMigratedAt;

  final int migratedServices;

  /// The window the home reports on. Not nullable: a user who never opened the
  /// setting gets [BillingCycle.monthlyDefault], which is the calendar month
  /// the app used before cycles existed.
  final BillingCycle billingCycle;

  /// When the guided setup finished. Stamped last, so an interrupted run leaves
  /// it null and the setup comes back on the next launch.
  final DateTime? setupCompletedAt;

  /// When the user left the guided setup through the close button. Whatever
  /// they had answered is kept, and they are not asked again — the home
  /// checklist is what picks the thread back up.
  final DateTime? setupSkippedAt;

  /// The preset key the user picked, or the profession they typed when no kit
  /// matched. Kept as research: the most frequent free-typed answers are the
  /// queue of presets still to build.
  final String? profession;

  /// Checklist steps that cannot be derived from the user's data — currently
  /// only whether they have opened the monthly summary.
  final Set<String> completedOnboardingSteps;

  /// Whether [billingCycle] is an answer the user gave, rather than the default
  /// standing in for one.
  ///
  /// [billingCycle] cannot express this on its own: it is non-nullable, and a
  /// user who deliberately chose "monthly" is indistinguishable from one who
  /// never opened the setting. Without the distinction, the confirmation card
  /// would ask people who have already answered.
  final bool hasExplicitBillingCycle;

  bool get hasMigratedCurrency => currencyMigratedAt != null;

  /// True once the setup is behind the user, whether they finished it or left
  /// it. Both are answers; neither is asked twice.
  bool get hasResolvedSetup => setupCompletedAt != null || setupSkippedAt != null;

  @override
  List<Object?> get props => [
    defaultCurrency,
    currencyMigratedAt,
    migratedServices,
    billingCycle,
    setupCompletedAt,
    setupSkippedAt,
    profession,
    completedOnboardingSteps,
    hasExplicitBillingCycle,
  ];
}
