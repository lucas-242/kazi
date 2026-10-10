// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ServiceFormController)
final serviceFormControllerProvider = ServiceFormControllerFamily._();

final class ServiceFormControllerProvider
    extends $AsyncNotifierProvider<ServiceFormController, ServiceFormState> {
  ServiceFormControllerProvider._({
    required ServiceFormControllerFamily super.from,
    required Service? super.argument,
  }) : super(
         retry: null,
         name: r'serviceFormControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$serviceFormControllerHash();

  @override
  String toString() {
    return r'serviceFormControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ServiceFormController create() => ServiceFormController();

  @override
  bool operator ==(Object other) {
    return other is ServiceFormControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$serviceFormControllerHash() =>
    r'df82348f3fe4ac3dfb32bab6e8d66e1603517c56';

final class ServiceFormControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ServiceFormController,
          AsyncValue<ServiceFormState>,
          ServiceFormState,
          FutureOr<ServiceFormState>,
          Service?
        > {
  ServiceFormControllerFamily._()
    : super(
        retry: null,
        name: r'serviceFormControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ServiceFormControllerProvider call({Service? service}) =>
      ServiceFormControllerProvider._(argument: service, from: this);

  @override
  String toString() => r'serviceFormControllerProvider';
}

abstract class _$ServiceFormController
    extends $AsyncNotifier<ServiceFormState> {
  late final _$args = ref.$arg as Service?;
  Service? get service => _$args;

  FutureOr<ServiceFormState> build({Service? service});
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<ServiceFormState>, ServiceFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ServiceFormState>, ServiceFormState>,
              AsyncValue<ServiceFormState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(service: _$args));
  }
}
