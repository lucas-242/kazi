// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_filters_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ServiceFiltersController)
const serviceFiltersControllerProvider = ServiceFiltersControllerFamily._();

final class ServiceFiltersControllerProvider
    extends $NotifierProvider<ServiceFiltersController, ServiceFiltersState> {
  const ServiceFiltersControllerProvider._({
    required ServiceFiltersControllerFamily super.from,
    required ({DateTime startDate, DateTime endDate, FastSearch fastSearch})
    super.argument,
  }) : super(
         retry: null,
         name: r'serviceFiltersControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$serviceFiltersControllerHash();

  @override
  String toString() {
    return r'serviceFiltersControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  ServiceFiltersController create() => ServiceFiltersController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServiceFiltersState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServiceFiltersState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ServiceFiltersControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$serviceFiltersControllerHash() =>
    r'65aa4a939eb24b18f08fb2a2f38bb201b836d1f5';

final class ServiceFiltersControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ServiceFiltersController,
          ServiceFiltersState,
          ServiceFiltersState,
          ServiceFiltersState,
          ({DateTime startDate, DateTime endDate, FastSearch fastSearch})
        > {
  const ServiceFiltersControllerFamily._()
    : super(
        retry: null,
        name: r'serviceFiltersControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ServiceFiltersControllerProvider call({
    required DateTime startDate,
    required DateTime endDate,
    required FastSearch fastSearch,
  }) => ServiceFiltersControllerProvider._(
    argument: (startDate: startDate, endDate: endDate, fastSearch: fastSearch),
    from: this,
  );

  @override
  String toString() => r'serviceFiltersControllerProvider';
}

abstract class _$ServiceFiltersController
    extends $Notifier<ServiceFiltersState> {
  late final _$args =
      ref.$arg
          as ({DateTime startDate, DateTime endDate, FastSearch fastSearch});
  DateTime get startDate => _$args.startDate;
  DateTime get endDate => _$args.endDate;
  FastSearch get fastSearch => _$args.fastSearch;

  ServiceFiltersState build({
    required DateTime startDate,
    required DateTime endDate,
    required FastSearch fastSearch,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(
      startDate: _$args.startDate,
      endDate: _$args.endDate,
      fastSearch: _$args.fastSearch,
    );
    final ref = this.ref as $Ref<ServiceFiltersState, ServiceFiltersState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ServiceFiltersState, ServiceFiltersState>,
              ServiceFiltersState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
