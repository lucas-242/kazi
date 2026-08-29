// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'client_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ClientFormController)
const clientFormControllerProvider = ClientFormControllerFamily._();

final class ClientFormControllerProvider
    extends $AsyncNotifierProvider<ClientFormController, ClientFormState> {
  const ClientFormControllerProvider._({
    required ClientFormControllerFamily super.from,
    required ClientEntry? super.argument,
  }) : super(
         retry: null,
         name: r'clientFormControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$clientFormControllerHash();

  @override
  String toString() {
    return r'clientFormControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ClientFormController create() => ClientFormController();

  @override
  bool operator ==(Object other) {
    return other is ClientFormControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$clientFormControllerHash() =>
    r'f264eb795adc5c884bccfede50f95f5c50ed4301';

final class ClientFormControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ClientFormController,
          AsyncValue<ClientFormState>,
          ClientFormState,
          FutureOr<ClientFormState>,
          ClientEntry?
        > {
  const ClientFormControllerFamily._()
    : super(
        retry: null,
        name: r'clientFormControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ClientFormControllerProvider call({ClientEntry? client}) =>
      ClientFormControllerProvider._(argument: client, from: this);

  @override
  String toString() => r'clientFormControllerProvider';
}

abstract class _$ClientFormController extends $AsyncNotifier<ClientFormState> {
  late final _$args = ref.$arg as ClientEntry?;
  ClientEntry? get client => _$args;

  FutureOr<ClientFormState> build({ClientEntry? client});
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(client: _$args);
    final ref = this.ref as $Ref<AsyncValue<ClientFormState>, ClientFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ClientFormState>, ClientFormState>,
              AsyncValue<ClientFormState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
