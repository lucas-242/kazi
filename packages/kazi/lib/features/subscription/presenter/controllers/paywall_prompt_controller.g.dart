// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paywall_prompt_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// App-wide signal used to request the paywall when a freemium limit is hit.
/// Creation controllers call [promptFor]; a single listener at the app shell
/// presents the paywall and then calls [dismiss] so the same limit can trigger
/// it again next time.

@ProviderFor(PaywallPromptController)
const paywallPromptControllerProvider = PaywallPromptControllerProvider._();

/// App-wide signal used to request the paywall when a freemium limit is hit.
/// Creation controllers call [promptFor]; a single listener at the app shell
/// presents the paywall and then calls [dismiss] so the same limit can trigger
/// it again next time.
final class PaywallPromptControllerProvider
    extends $NotifierProvider<PaywallPromptController, LimitType?> {
  /// App-wide signal used to request the paywall when a freemium limit is hit.
  /// Creation controllers call [promptFor]; a single listener at the app shell
  /// presents the paywall and then calls [dismiss] so the same limit can trigger
  /// it again next time.
  const PaywallPromptControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paywallPromptControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paywallPromptControllerHash();

  @$internal
  @override
  PaywallPromptController create() => PaywallPromptController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LimitType? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LimitType?>(value),
    );
  }
}

String _$paywallPromptControllerHash() =>
    r'859571eb3de823c3c3ae997a824f8d1134fe8d71';

/// App-wide signal used to request the paywall when a freemium limit is hit.
/// Creation controllers call [promptFor]; a single listener at the app shell
/// presents the paywall and then calls [dismiss] so the same limit can trigger
/// it again next time.

abstract class _$PaywallPromptController extends $Notifier<LimitType?> {
  LimitType? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<LimitType?, LimitType?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LimitType?, LimitType?>,
              LimitType?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
