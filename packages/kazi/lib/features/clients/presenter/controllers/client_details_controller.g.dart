// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_details_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ClientDetailsController)
const clientDetailsControllerProvider = ClientDetailsControllerFamily._();

final class ClientDetailsControllerProvider
    extends $NotifierProvider<ClientDetailsController, ClientDetailsState> {
  const ClientDetailsControllerProvider._({
    required ClientDetailsControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'clientDetailsControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$clientDetailsControllerHash();

  @override
  String toString() {
    return r'clientDetailsControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ClientDetailsController create() => ClientDetailsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClientDetailsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClientDetailsState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ClientDetailsControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$clientDetailsControllerHash() =>
    r'c6baf953e1ff2789727ae94ec013fe20d9470b85';

final class ClientDetailsControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ClientDetailsController,
          ClientDetailsState,
          ClientDetailsState,
          ClientDetailsState,
          String
        > {
  const ClientDetailsControllerFamily._()
    : super(
        retry: null,
        name: r'clientDetailsControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ClientDetailsControllerProvider call({required String clientId}) =>
      ClientDetailsControllerProvider._(argument: clientId, from: this);

  @override
  String toString() => r'clientDetailsControllerProvider';
}

abstract class _$ClientDetailsController extends $Notifier<ClientDetailsState> {
  late final _$args = ref.$arg as String;
  String get clientId => _$args;

  ClientDetailsState build({required String clientId});
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(clientId: _$args);
    final ref = this.ref as $Ref<ClientDetailsState, ClientDetailsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ClientDetailsState, ClientDetailsState>,
              ClientDetailsState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
