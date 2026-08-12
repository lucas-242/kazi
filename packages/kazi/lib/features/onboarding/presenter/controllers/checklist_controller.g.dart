// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checklist_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The five-step trail on the home, and the rules for when it is there at all.

@ProviderFor(ChecklistController)
const checklistControllerProvider = ChecklistControllerProvider._();

/// The five-step trail on the home, and the rules for when it is there at all.
final class ChecklistControllerProvider
    extends $AsyncNotifierProvider<ChecklistController, ChecklistState> {
  /// The five-step trail on the home, and the rules for when it is there at all.
  const ChecklistControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'checklistControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$checklistControllerHash();

  @$internal
  @override
  ChecklistController create() => ChecklistController();
}

String _$checklistControllerHash() =>
    r'c6ec5bf61401bfdb940f05de6efb91d417e58448';

/// The five-step trail on the home, and the rules for when it is there at all.

abstract class _$ChecklistController extends $AsyncNotifier<ChecklistState> {
  FutureOr<ChecklistState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<ChecklistState>, ChecklistState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ChecklistState>, ChecklistState>,
              AsyncValue<ChecklistState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
