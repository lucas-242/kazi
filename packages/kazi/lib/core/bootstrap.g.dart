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

String _$appBootstrapHash() => r'd5ffd45813999b5956f01b9df41e174e327d2bbc';
