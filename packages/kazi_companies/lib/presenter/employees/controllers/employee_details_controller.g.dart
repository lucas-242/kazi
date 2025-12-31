// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_details_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EmployeeDetailsController)
const employeeDetailsControllerProvider = EmployeeDetailsControllerFamily._();

final class EmployeeDetailsControllerProvider extends $AsyncNotifierProvider<
    EmployeeDetailsController, EmployeeDetailsInitialState> {
  const EmployeeDetailsControllerProvider._(
      {required EmployeeDetailsControllerFamily super.from,
      required ({
        User? employee,
        int? employeeId,
      })
          super.argument})
      : super(
          retry: null,
          name: r'employeeDetailsControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$employeeDetailsControllerHash();

  @override
  String toString() {
    return r'employeeDetailsControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  EmployeeDetailsController create() => EmployeeDetailsController();

  @override
  bool operator ==(Object other) {
    return other is EmployeeDetailsControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$employeeDetailsControllerHash() =>
    r'8894a0f08a021173fdc1fd052d773daeb8eb3172';

final class EmployeeDetailsControllerFamily extends $Family
    with
        $ClassFamilyOverride<
            EmployeeDetailsController,
            AsyncValue<EmployeeDetailsInitialState>,
            EmployeeDetailsInitialState,
            FutureOr<EmployeeDetailsInitialState>,
            ({
              User? employee,
              int? employeeId,
            })> {
  const EmployeeDetailsControllerFamily._()
      : super(
          retry: null,
          name: r'employeeDetailsControllerProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  EmployeeDetailsControllerProvider call({
    User? employee,
    int? employeeId,
  }) =>
      EmployeeDetailsControllerProvider._(argument: (
        employee: employee,
        employeeId: employeeId,
      ), from: this);

  @override
  String toString() => r'employeeDetailsControllerProvider';
}

abstract class _$EmployeeDetailsController
    extends $AsyncNotifier<EmployeeDetailsInitialState> {
  late final _$args = ref.$arg as ({
    User? employee,
    int? employeeId,
  });
  User? get employee => _$args.employee;
  int? get employeeId => _$args.employeeId;

  FutureOr<EmployeeDetailsInitialState> build({
    User? employee,
    int? employeeId,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      employee: _$args.employee,
      employeeId: _$args.employeeId,
    );
    final ref = this.ref as $Ref<AsyncValue<EmployeeDetailsInitialState>,
        EmployeeDetailsInitialState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<EmployeeDetailsInitialState>,
            EmployeeDetailsInitialState>,
        AsyncValue<EmployeeDetailsInitialState>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
