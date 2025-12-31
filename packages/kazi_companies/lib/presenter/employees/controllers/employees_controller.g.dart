// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employees_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EmployeesController)
const employeesControllerProvider = EmployeesControllerProvider._();

final class EmployeesControllerProvider
    extends $AsyncNotifierProvider<EmployeesController, EmployeesInitialState> {
  const EmployeesControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'employeesControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$employeesControllerHash();

  @$internal
  @override
  EmployeesController create() => EmployeesController();
}

String _$employeesControllerHash() =>
    r'c871e5534269e6856d1717a363010c79ad5ed44f';

abstract class _$EmployeesController
    extends $AsyncNotifier<EmployeesInitialState> {
  FutureOr<EmployeesInitialState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref
        as $Ref<AsyncValue<EmployeesInitialState>, EmployeesInitialState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<EmployeesInitialState>, EmployeesInitialState>,
        AsyncValue<EmployeesInitialState>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
