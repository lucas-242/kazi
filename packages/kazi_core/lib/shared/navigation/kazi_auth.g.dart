// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kazi_auth.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Overridable per app. Throws until an app injects its implementation.

@ProviderFor(kaziAuthService)
const kaziAuthServiceProvider = KaziAuthServiceProvider._();

/// Overridable per app. Throws until an app injects its implementation.

final class KaziAuthServiceProvider extends $FunctionalProvider<KaziAuthService,
    KaziAuthService, KaziAuthService> with $Provider<KaziAuthService> {
  /// Overridable per app. Throws until an app injects its implementation.
  const KaziAuthServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'kaziAuthServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$kaziAuthServiceHash();

  @$internal
  @override
  $ProviderElement<KaziAuthService> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  KaziAuthService create(Ref ref) {
    return kaziAuthService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KaziAuthService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KaziAuthService>(value),
    );
  }
}

String _$kaziAuthServiceHash() => r'fa9d696306434078c2d92dc060348417c5832265';

/// Overridable per app. Resolves whether the onboarding flow was completed.

@ProviderFor(kaziOnboardingCompleted)
const kaziOnboardingCompletedProvider = KaziOnboardingCompletedProvider._();

/// Overridable per app. Resolves whether the onboarding flow was completed.

final class KaziOnboardingCompletedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Overridable per app. Resolves whether the onboarding flow was completed.
  const KaziOnboardingCompletedProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'kaziOnboardingCompletedProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$kaziOnboardingCompletedHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return kaziOnboardingCompleted(ref);
  }
}

String _$kaziOnboardingCompletedHash() =>
    r'c121e4b5d64bd6bb579afae382bb81a90def742b';

/// Minimum time the splash stays visible so its animation can play, even when
/// startup data resolves faster. Overridable per app; defaults to no delay.

@ProviderFor(kaziMinimumSplashDuration)
const kaziMinimumSplashDurationProvider = KaziMinimumSplashDurationProvider._();

/// Minimum time the splash stays visible so its animation can play, even when
/// startup data resolves faster. Overridable per app; defaults to no delay.

final class KaziMinimumSplashDurationProvider
    extends $FunctionalProvider<Duration, Duration, Duration>
    with $Provider<Duration> {
  /// Minimum time the splash stays visible so its animation can play, even when
  /// startup data resolves faster. Overridable per app; defaults to no delay.
  const KaziMinimumSplashDurationProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'kaziMinimumSplashDurationProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$kaziMinimumSplashDurationHash();

  @$internal
  @override
  $ProviderElement<Duration> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Duration create(Ref ref) {
    return kaziMinimumSplashDuration(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Duration value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Duration>(value),
    );
  }
}

String _$kaziMinimumSplashDurationHash() =>
    r'd5875cf0af1840194817f390d70c2b42cf3d66b2';

@ProviderFor(KaziIsAuthenticated)
const kaziIsAuthenticatedProvider = KaziIsAuthenticatedProvider._();

final class KaziIsAuthenticatedProvider
    extends $StreamNotifierProvider<KaziIsAuthenticated, bool> {
  const KaziIsAuthenticatedProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'kaziIsAuthenticatedProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$kaziIsAuthenticatedHash();

  @$internal
  @override
  KaziIsAuthenticated create() => KaziIsAuthenticated();
}

String _$kaziIsAuthenticatedHash() =>
    r'e72cfa6a517687d3190a5446f8099a959579e701';

abstract class _$KaziIsAuthenticated extends $StreamNotifier<bool> {
  Stream<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<bool>, bool>,
        AsyncValue<bool>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

@ProviderFor(KaziAppStartup)
const kaziAppStartupProvider = KaziAppStartupProvider._();

final class KaziAppStartupProvider
    extends $AsyncNotifierProvider<KaziAppStartup, KaziStartupState> {
  const KaziAppStartupProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'kaziAppStartupProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$kaziAppStartupHash();

  @$internal
  @override
  KaziAppStartup create() => KaziAppStartup();
}

String _$kaziAppStartupHash() => r'71a67bdae66c6b698220498c0cd42885186340c0';

abstract class _$KaziAppStartup extends $AsyncNotifier<KaziStartupState> {
  FutureOr<KaziStartupState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<KaziStartupState>, KaziStartupState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<KaziStartupState>, KaziStartupState>,
        AsyncValue<KaziStartupState>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
