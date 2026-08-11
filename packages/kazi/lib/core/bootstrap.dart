import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kazi/features/app_update/app_update.dart';
import 'package:kazi/features/settings/settings.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

part 'bootstrap.g.dart';

/// Everything the app has to have in place before the router can choose a
/// screen, run **while the branded splash is on screen**.
///
/// `main()` keeps only what genuinely cannot wait: the environment, Firebase,
/// Crashlytics and the billing SDK's identity. Those are either a prerequisite
/// for constructing the providers at all, or — for Crashlytics — the very thing
/// that reports a failure in the rest of this file. Everything below is slow,
/// network-bound and not needed to draw a splash, so it belongs here: awaited
/// against the splash's own minimum duration rather than added to it.
///
/// Nothing in here throws. Every step is individually fail-open, because the
/// only outcome worse than a stale feature flag is a person who cannot get past
/// the splash.
@riverpod
Future<void> appBootstrap(Ref ref) async {
  // Ads are needed no earlier than the first list that shows one, so this runs
  // alongside the config work instead of in front of it.
  final ads = _guard(
    'MobileAds.initialize',
    () => MobileAds.instance.initialize(),
    ref,
  );

  // Strictly ordered: the update check reads its thresholds from Remote Config,
  // so it has to run after the fetch — otherwise it silently compares against
  // the in-app defaults and no forced update is ever announced.
  await _guard(
    'FeatureFlagService.init',
    () => ref.read(featureFlagServiceProvider).init(),
    ref,
  );

  await _guard(
    'AppUpdateController.check',
    () => ref.read(appUpdateControllerProvider.notifier).check(),
    ref,
  );

  // Has to be decided before the home renders: every total on it is meaningless
  // until the user's currency is known.
  await _guard(
    'CurrencyMigrationController.check',
    () => ref.read(currencyMigrationControllerProvider.notifier).check(),
    ref,
  );

  await ads;
}

/// Runs [step], reporting a failure to Crashlytics instead of propagating it.
Future<void> _guard(String name, Future<void> Function() step, Ref ref) async {
  try {
    await step();
  } catch (exception, stackTrace) {
    Log.error('Bootstrap step "$name" failed: $exception');
    ref.read(crashlyticsServiceProvider).log(exception, stackTrace);
  }
}
