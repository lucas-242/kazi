// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'privacy_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The user's answers about being measured.
///
/// Stored locally rather than on the account document: signing out clears local
/// storage, so the next person on the device is asked for themselves instead of
/// inheriting a stranger's yes.

@ProviderFor(PrivacyController)
const privacyControllerProvider = PrivacyControllerProvider._();

/// The user's answers about being measured.
///
/// Stored locally rather than on the account document: signing out clears local
/// storage, so the next person on the device is asked for themselves instead of
/// inheriting a stranger's yes.
final class PrivacyControllerProvider
    extends $AsyncNotifierProvider<PrivacyController, PrivacySettings> {
  /// The user's answers about being measured.
  ///
  /// Stored locally rather than on the account document: signing out clears local
  /// storage, so the next person on the device is asked for themselves instead of
  /// inheriting a stranger's yes.
  const PrivacyControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'privacyControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$privacyControllerHash();

  @$internal
  @override
  PrivacyController create() => PrivacyController();
}

String _$privacyControllerHash() => r'2e2c9cb04eeee0ac1784b17e4532029f130e5309';

/// The user's answers about being measured.
///
/// Stored locally rather than on the account document: signing out clears local
/// storage, so the next person on the device is asked for themselves instead of
/// inheriting a stranger's yes.

abstract class _$PrivacyController extends $AsyncNotifier<PrivacySettings> {
  FutureOr<PrivacySettings> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<PrivacySettings>, PrivacySettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PrivacySettings>, PrivacySettings>,
              AsyncValue<PrivacySettings>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Read synchronously by the composite service on every call.
///
/// Defaults to `false` while the store loads: the handful of events in the first
/// milliseconds are worth less than one event sent for somebody who objected.

@ProviderFor(isAnalyticsAllowed)
const isAnalyticsAllowedProvider = IsAnalyticsAllowedProvider._();

/// Read synchronously by the composite service on every call.
///
/// Defaults to `false` while the store loads: the handful of events in the first
/// milliseconds are worth less than one event sent for somebody who objected.

final class IsAnalyticsAllowedProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Read synchronously by the composite service on every call.
  ///
  /// Defaults to `false` while the store loads: the handful of events in the first
  /// milliseconds are worth less than one event sent for somebody who objected.
  const IsAnalyticsAllowedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isAnalyticsAllowedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isAnalyticsAllowedHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isAnalyticsAllowed(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isAnalyticsAllowedHash() =>
    r'fdc54d41bc55c27efe73aadc88cff5f3eac74e94';

@ProviderFor(isReplayAllowed)
const isReplayAllowedProvider = IsReplayAllowedProvider._();

final class IsReplayAllowedProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  const IsReplayAllowedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isReplayAllowedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isReplayAllowedHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return isReplayAllowed(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isReplayAllowedHash() => r'ba114db9924ac67d68448ca0ef8e9835e2f4ebf0';
