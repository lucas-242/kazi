// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'agenda_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AgendaController)
final agendaControllerProvider = AgendaControllerProvider._();

final class AgendaControllerProvider
    extends $NotifierProvider<AgendaController, AgendaState> {
  AgendaControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'agendaControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$agendaControllerHash();

  @$internal
  @override
  AgendaController create() => AgendaController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AgendaState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AgendaState>(value),
    );
  }
}

String _$agendaControllerHash() => r'052559950f01f84d94262224a37479c651be3c97';

abstract class _$AgendaController extends $Notifier<AgendaState> {
  AgendaState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AgendaState, AgendaState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AgendaState, AgendaState>,
              AgendaState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
