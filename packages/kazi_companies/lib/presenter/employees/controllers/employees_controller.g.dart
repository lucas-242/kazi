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
    extends $AsyncNotifierProvider<EmployeesController, EmployeesState> {
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
    r'967551253974ff72ca9b2c1cd5ec84f6194dc37d';

abstract class _$EmployeesController extends $AsyncNotifier<EmployeesState> {
  FutureOr<EmployeesState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<EmployeesState>, EmployeesState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<EmployeesState>, EmployeesState>,
        AsyncValue<EmployeesState>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
