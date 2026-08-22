// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paywall_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PaywallController)
const paywallControllerProvider = PaywallControllerProvider._();

final class PaywallControllerProvider
    extends $AsyncNotifierProvider<PaywallController, PaywallState> {
  const PaywallControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paywallControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paywallControllerHash();

  @$internal
  @override
  PaywallController create() => PaywallController();
}

String _$paywallControllerHash() => r'f05148ef1f77e913c6d6a194f7a8bc149d035ade';

abstract class _$PaywallController extends $AsyncNotifier<PaywallState> {
  FutureOr<PaywallState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<PaywallState>, PaywallState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PaywallState>, PaywallState>,
              AsyncValue<PaywallState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
