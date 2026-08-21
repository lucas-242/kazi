/// Every event the app emits, in the order of the journey they measure.
///
/// Names are snake_case and under 40 characters, which is what Firebase
/// Analytics accepts. Parameter names follow the same rule, and string values
/// are truncated to 100 characters by the scrubber.
///
/// **[isKey] decides where the event lands.** A key event goes to both sinks;
/// everything else goes to PostHog only. The split is not cosmetic: Firebase
/// caps a project at 500 distinct event names and 25 parameters per event, and
/// a Firebase stream diluted with diagnostics stops being usable as an Ads
/// audience. PostHog has neither limit and is where the funnels live.
///
/// **Nothing here carries a monetary amount, a name, an e-mail or free text.**
/// Only shape: bucketed counts, ISO codes, enum names and booleans. See
/// `AnalyticsScrubber`, which enforces this at the edge rather than trusting it.
enum AnalyticsEvent {
  // --------------------------------------------------------------- auth

  /// A sign-in provider was tapped. Parameter: `provider`.
  loginStarted('login_started'),

  /// Sign-in succeeded. Parameters: `provider`, `is_new_user`.
  loginCompleted('login_completed', isKey: true),

  /// Sign-in failed. Parameters: `provider`, `reason` — the error code, never
  /// the message, which can carry the address the person typed.
  loginFailed('login_failed'),

  /// The user signed out deliberately.
  logout('logout'),

  // ---------------------------------------------------- onboarding / setup

  /// The guided setup opened. Denominator for every step-level drop-off.
  setupStarted('setup_started'),

  /// A setup step was shown. Parameter: `step`.
  setupStepViewed('setup_step_viewed'),

  /// The user left through the close button. Parameters: `step`,
  /// `seconds_on_step` — the screen concentrating the abandonment is the one
  /// asking too much, and the seconds say whether they read it or fled it.
  setupExited('setup_exited'),

  /// The setup finished. Parameters: `seconds` (login to first number, whose
  /// target is under two minutes), `seeded_types`, `registered_service`,
  /// `profession`.
  setupCompleted('setup_completed', isKey: true),

  /// A home-checklist step was completed. Parameter: `step`.
  checklistStepCompleted('checklist_step_completed'),

  /// A contextual hint was acknowledged. Parameter: `hint`.
  hintDismissed('hint_dismissed'),

  /// The release announcement was shown. Parameter: `version`.
  whatsNewViewed('whats_new_viewed'),

  /// The release announcement was closed. Parameters: `version`, `seconds`.
  whatsNewDismissed('whats_new_dismissed'),

  /// An active-user nudge was rendered. Parameter: `kind`.
  nudgeShown('nudge_shown'),

  /// An active-user nudge was acted on. Parameter: `kind`.
  nudgeActioned('nudge_actioned'),

  // ----------------------------------------------------------- activation

  /// The service form opened. Parameters: `source` (fab/home/list/setup),
  /// `is_first`.
  serviceFormOpened('service_form_opened'),

  /// The service form was left without saving. Parameters: `seconds`,
  /// `filled_fields`, `last_field`, `had_validation_error`.
  ///
  /// The single most important event here. An abandoned creation form is the
  /// first bottleneck of any tracking app, and until now it was invisible —
  /// the app could not distinguish "did not want to" from "could not".
  serviceFormAbandoned('service_form_abandoned'),

  /// A service was registered. Parameters: `quantity`, `currency`,
  /// `has_client`, `commission_configured`, `seconds_to_create`.
  serviceCreated('service_created'),

  /// The account's first service ever. The activation milestone, so it is a
  /// conversion in Firebase too.
  firstServiceCreated('first_service_created', isKey: true),

  /// An existing service was edited.
  serviceUpdated('service_updated'),

  /// A service was removed. Parameter: `days_old`.
  serviceDeleted('service_deleted'),

  /// A service type was added. Parameter: `source` (setup/catalog/quick_add).
  serviceTypeCreated('service_type_created'),

  /// A client was added. Parameter: `source` (clients/quick_add).
  clientCreated('client_created'),

  /// A receipt was produced for a service.
  receiptGenerated('receipt_generated'),

  // ------------------------------------------------------ perceived value

  /// The home screen rendered. Parameters: `period`, `has_data`,
  /// `services_bucket`, `unconverted_count`.
  dashboardViewed('dashboard_viewed'),

  /// The dashboard period changed. Parameters: `from`, `to`.
  dashboardPeriodChanged('dashboard_period_changed'),

  /// The home screen rendered with nothing on it. A strong churn signal on any
  /// session that is not the first.
  dashboardEmptyStateSeen('dashboard_empty_state_seen'),

  /// A filter was applied to the service list. Parameter: `filter`.
  filterApplied('filter_applied'),

  // ---------------------------------------------------------- currency

  /// The blocking currency migration was presented.
  currencyMigrationShown('currency_migration_shown'),

  /// The migration completed. Parameters: `currency`, `backfilled_bucket`.
  currencyMigrationConfirmed('currency_migration_confirmed', isKey: true),

  /// The migration failed and will be asked again next launch. Parameter:
  /// `reason`.
  currencyMigrationFailed('currency_migration_failed'),

  /// The default currency changed. Parameters: `from`, `to`.
  currencyChanged('currency_changed'),

  /// A conversion could not be performed because no rate covered the pair.
  /// Parameter: `context` (totals/form_switch).
  ///
  /// Measures, for the first time, what the silent exchange-rate fallback
  /// actually costs. Until now nobody knew how often a total came out partial.
  ratesUnavailable('rates_unavailable'),

  /// The only user-visible currency failure: switching the form's currency was
  /// refused because relabelling the typed amount would have been a lie.
  formCurrencySwitchRefused('form_currency_switch_refused'),

  // ------------------------------------------------- freemium / paywall

  /// A creation was blocked by a freemium limit. Parameters: `limit_type`,
  /// `tier`. The top of the monetization funnel.
  limitReached('limit_reached'),

  /// The paywall was presented. Parameters: `source` (limit/menu),
  /// `limit_type`, `tier`, `is_trial_eligible`.
  paywallShown('paywall_shown'),

  /// The paywall was closed without purchasing. Parameters: `seconds`,
  /// `source`.
  paywallDismissed('paywall_dismissed'),

  /// The subscribe button was tapped. Parameter: `is_trial_eligible`.
  subscribeTapped('subscribe_tapped'),

  /// A subscription (or trial) started. Parameter: `is_trial`.
  subscriptionStarted('subscription_started', isKey: true),

  /// The purchase failed. Parameter: `reason` — the error code only.
  subscriptionPurchaseFailed('subscription_purchase_failed'),

  /// A previous purchase was restored.
  subscriptionRestored('subscription_restored'),

  // -------------------------------------------------------------- ads

  /// The post-creation interstitial was displayed. Parameter: `after`.
  interstitialShown('interstitial_shown'),

  /// The interstitial was requested but had nothing to show.
  interstitialLoadFailed('interstitial_load_failed'),

  // ------------------------------------------------- errors and friction

  /// An error message was put in front of the user. Parameters: `code`,
  /// `screen`.
  ///
  /// Emitted from `BaseNotifier`, which every controller in the app funnels
  /// through — so this covers handled errors app-wide. Crashlytics only ever
  /// saw the crashes; this sees what people actually run into.
  errorShown('error_shown'),

  /// The friction detector fired. Parameters: `kind`, `screen`, `count`.
  frictionDetected('friction_detected'),

  /// A form refused to submit. Parameters: `form`, `field`.
  formValidationFailed('form_validation_failed');

  const AnalyticsEvent(this.name, {this.isKey = false});

  /// The wire name, identical in both sinks so a Firebase audience and a
  /// PostHog funnel can be talked about with one vocabulary.
  final String name;

  /// Whether the event also goes to Firebase Analytics. See the class doc.
  final bool isKey;
}
