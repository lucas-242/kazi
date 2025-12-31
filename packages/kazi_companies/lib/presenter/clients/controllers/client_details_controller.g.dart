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
    extends $AsyncNotifierProvider<ClientDetailsController, ClientInfo> {
  const ClientDetailsControllerProvider._(
      {required ClientDetailsControllerFamily super.from,
      required (
        String?,
        ClientInfo?,
      )
          super.argument})
      : super(
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
        '$argument';
  }

  @$internal
  @override
  ClientDetailsController create() => ClientDetailsController();

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
    r'9fd5a9cc225aa68b999be237091b2b440edd108d';

final class ClientDetailsControllerFamily extends $Family
    with
        $ClassFamilyOverride<
            ClientDetailsController,
            AsyncValue<ClientInfo>,
            ClientInfo,
            FutureOr<ClientInfo>,
            (
              String?,
              ClientInfo?,
            )> {
  const ClientDetailsControllerFamily._()
      : super(
          retry: null,
          name: r'clientDetailsControllerProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  ClientDetailsControllerProvider call(
    String? clientId,
    ClientInfo? clientInfo,
  ) =>
      ClientDetailsControllerProvider._(argument: (
        clientId,
        clientInfo,
      ), from: this);

  @override
  String toString() => r'clientDetailsControllerProvider';
}

abstract class _$ClientDetailsController extends $AsyncNotifier<ClientInfo> {
  late final _$args = ref.$arg as (
    String?,
    ClientInfo?,
  );
  String? get clientId => _$args.$1;
  ClientInfo? get clientInfo => _$args.$2;

  FutureOr<ClientInfo> build(
    String? clientId,
    ClientInfo? clientInfo,
  );
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      _$args.$1,
      _$args.$2,
    );
    final ref = this.ref as $Ref<AsyncValue<ClientInfo>, ClientInfo>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<ClientInfo>, ClientInfo>,
        AsyncValue<ClientInfo>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
