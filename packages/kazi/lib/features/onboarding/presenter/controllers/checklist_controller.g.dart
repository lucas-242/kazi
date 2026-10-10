// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checklist_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The five-step trail on the home, and the rules for when it is there at all.

@ProviderFor(ChecklistController)
final checklistControllerProvider = ChecklistControllerProvider._();

/// The five-step trail on the home, and the rules for when it is there at all.
final class ChecklistControllerProvider
    extends $AsyncNotifierProvider<ChecklistController, ChecklistState> {
  /// The five-step trail on the home, and the rules for when it is there at all.
  ChecklistControllerProvider._()
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
    r'cc481dc533f9d6f1d10419f2574207d472bf6bea';

/// The five-step trail on the home, and the rules for when it is there at all.

abstract class _$ChecklistController extends $AsyncNotifier<ChecklistState> {
  FutureOr<ChecklistState> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<ChecklistState>, ChecklistState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<ChecklistState>, ChecklistState>,
              AsyncValue<ChecklistState>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
