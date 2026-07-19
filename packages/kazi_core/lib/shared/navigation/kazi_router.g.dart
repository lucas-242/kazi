// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kazi_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether a mandatory app update is currently required. Overridable per app
/// (defaults to `false`, i.e. no forced update). When it becomes `true` and the
/// config declares a [KaziRouterConfig.forcedUpdateRoute], the router locks the
/// user onto that route.

@ProviderFor(kaziForcedUpdateRequired)
const kaziForcedUpdateRequiredProvider = KaziForcedUpdateRequiredProvider._();

/// Whether a mandatory app update is currently required. Overridable per app
/// (defaults to `false`, i.e. no forced update). When it becomes `true` and the
/// config declares a [KaziRouterConfig.forcedUpdateRoute], the router locks the
/// user onto that route.

final class KaziForcedUpdateRequiredProvider
    extends $FunctionalProvider<bool, bool, bool> with $Provider<bool> {
  /// Whether a mandatory app update is currently required. Overridable per app
  /// (defaults to `false`, i.e. no forced update). When it becomes `true` and the
  /// config declares a [KaziRouterConfig.forcedUpdateRoute], the router locks the
  /// user onto that route.
  const KaziForcedUpdateRequiredProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'kaziForcedUpdateRequiredProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$kaziForcedUpdateRequiredHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return kaziForcedUpdateRequired(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$kaziForcedUpdateRequiredHash() =>
    r'9ac694083d1ede967a0f9273a3d5a10ee48954bb';

/// Overridable per app. Throws until an app injects its configuration.

@ProviderFor(kaziRouterConfig)
const kaziRouterConfigProvider = KaziRouterConfigProvider._();

/// Overridable per app. Throws until an app injects its configuration.

final class KaziRouterConfigProvider extends $FunctionalProvider<
    KaziRouterConfig,
    KaziRouterConfig,
    KaziRouterConfig> with $Provider<KaziRouterConfig> {
  /// Overridable per app. Throws until an app injects its configuration.
  const KaziRouterConfigProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'kaziRouterConfigProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$kaziRouterConfigHash();

  @$internal
  @override
  $ProviderElement<KaziRouterConfig> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  KaziRouterConfig create(Ref ref) {
    return kaziRouterConfig(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KaziRouterConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KaziRouterConfig>(value),
    );
  }
}

String _$kaziRouterConfigHash() => r'996ffe01cb65d5728bf67cb0bbe972bdbddc9228';

/// Builds the shared [GoRouter] and wires [KaziNavigator] to it.

@ProviderFor(kaziRouter)
const kaziRouterProvider = KaziRouterProvider._();

/// Builds the shared [GoRouter] and wires [KaziNavigator] to it.

final class KaziRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// Builds the shared [GoRouter] and wires [KaziNavigator] to it.
  const KaziRouterProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'kaziRouterProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$kaziRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return kaziRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$kaziRouterHash() => r'abc63a7d4d8eb60ac56e62011a6e1620baa5b5ba';
