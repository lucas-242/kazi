// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'privacy_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The user's answers about being measured, and the only thing allowed to turn
/// the telemetry on.
///
/// Stored locally rather than on the account document, and that is deliberate:
/// signing out clears local storage (`sign_out_dialog.dart`), so the next
/// person to use the device is asked for themselves instead of inheriting a
/// stranger's yes. The cost — the same person re-answering after a sign-out —
/// is the right side to err on for consent.
///
/// Fail-closed: an unreadable store resolves to "no objection recorded, replay
/// not consented", which runs the events and records nothing.

@ProviderFor(PrivacyController)
const privacyControllerProvider = PrivacyControllerProvider._();

/// The user's answers about being measured, and the only thing allowed to turn
/// the telemetry on.
///
/// Stored locally rather than on the account document, and that is deliberate:
/// signing out clears local storage (`sign_out_dialog.dart`), so the next
/// person to use the device is asked for themselves instead of inheriting a
/// stranger's yes. The cost — the same person re-answering after a sign-out —
/// is the right side to err on for consent.
///
/// Fail-closed: an unreadable store resolves to "no objection recorded, replay
/// not consented", which runs the events and records nothing.
final class PrivacyControllerProvider
    extends $AsyncNotifierProvider<PrivacyController, PrivacySettings> {
  /// The user's answers about being measured, and the only thing allowed to turn
  /// the telemetry on.
  ///
  /// Stored locally rather than on the account document, and that is deliberate:
  /// signing out clears local storage (`sign_out_dialog.dart`), so the next
  /// person to use the device is asked for themselves instead of inheriting a
  /// stranger's yes. The cost — the same person re-answering after a sign-out —
  /// is the right side to err on for consent.
  ///
  /// Fail-closed: an unreadable store resolves to "no objection recorded, replay
  /// not consented", which runs the events and records nothing.
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

/// The user's answers about being measured, and the only thing allowed to turn
/// the telemetry on.
///
/// Stored locally rather than on the account document, and that is deliberate:
/// signing out clears local storage (`sign_out_dialog.dart`), so the next
/// person to use the device is asked for themselves instead of inheriting a
/// stranger's yes. The cost — the same person re-answering after a sign-out —
/// is the right side to err on for consent.
///
/// Fail-closed: an unreadable store resolves to "no objection recorded, replay
/// not consented", which runs the events and records nothing.

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

/// Whether events may be collected at all. Read synchronously by the composite
/// service on every call, so withdrawing consent takes effect on the next
/// event rather than the next launch.
///
/// Defaults to `false` while the store is still loading: the handful of events
/// in the first milliseconds are worth less than the chance of sending one for
/// somebody who had already objected.

@ProviderFor(isAnalyticsAllowed)
const isAnalyticsAllowedProvider = IsAnalyticsAllowedProvider._();

/// Whether events may be collected at all. Read synchronously by the composite
/// service on every call, so withdrawing consent takes effect on the next
/// event rather than the next launch.
///
/// Defaults to `false` while the store is still loading: the handful of events
/// in the first milliseconds are worth less than the chance of sending one for
/// somebody who had already objected.

final class IsAnalyticsAllowedProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether events may be collected at all. Read synchronously by the composite
  /// service on every call, so withdrawing consent takes effect on the next
  /// event rather than the next launch.
  ///
  /// Defaults to `false` while the store is still loading: the handful of events
  /// in the first milliseconds are worth less than the chance of sending one for
  /// somebody who had already objected.
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

/// Whether this user consented to having sessions recorded.

@ProviderFor(isReplayAllowed)
const isReplayAllowedProvider = IsReplayAllowedProvider._();

/// Whether this user consented to having sessions recorded.

final class IsReplayAllowedProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Whether this user consented to having sessions recorded.
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
