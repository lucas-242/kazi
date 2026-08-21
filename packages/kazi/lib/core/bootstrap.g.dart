// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bootstrap.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(appBootstrap)
const appBootstrapProvider = AppBootstrapProvider._();

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

final class AppBootstrapProvider
    extends $FunctionalProvider<AsyncValue<void>, void, FutureOr<void>>
    with $FutureModifier<void>, $FutureProvider<void> {
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
  const AppBootstrapProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appBootstrapProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appBootstrapHash();

  @$internal
  @override
  $FutureProviderElement<void> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<void> create(Ref ref) {
    return appBootstrap(ref);
  }
}

String _$appBootstrapHash() => r'ebf047f47d09c7f6f2b53de2c7dec2fa934e9e93';

/// Carries a change made in Menu › Privacy down to the SDKs.
///
/// The composite service already checks the switch on every event, so stopping
/// there would silence everything this app sends. It would **not** silence what
/// the SDKs send on their own — `session_start`, `$app_opened`, and the replay
/// already in progress — and a switch that leaves those running is a switch
/// that does not do what its label says.

@ProviderFor(analyticsConsentSync)
const analyticsConsentSyncProvider = AnalyticsConsentSyncProvider._();

/// Carries a change made in Menu › Privacy down to the SDKs.
///
/// The composite service already checks the switch on every event, so stopping
/// there would silence everything this app sends. It would **not** silence what
/// the SDKs send on their own — `session_start`, `$app_opened`, and the replay
/// already in progress — and a switch that leaves those running is a switch
/// that does not do what its label says.

final class AnalyticsConsentSyncProvider
    extends $FunctionalProvider<void, void, void>
    with $Provider<void> {
  /// Carries a change made in Menu › Privacy down to the SDKs.
  ///
  /// The composite service already checks the switch on every event, so stopping
  /// there would silence everything this app sends. It would **not** silence what
  /// the SDKs send on their own — `session_start`, `$app_opened`, and the replay
  /// already in progress — and a switch that leaves those running is a switch
  /// that does not do what its label says.
  const AnalyticsConsentSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'analyticsConsentSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$analyticsConsentSyncHash();

  @$internal
  @override
  $ProviderElement<void> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  void create(Ref ref) {
    return analyticsConsentSync(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$analyticsConsentSyncHash() =>
    r'df89320ac5b50f2f24d2b0c6b560e2d9f30f448b';
