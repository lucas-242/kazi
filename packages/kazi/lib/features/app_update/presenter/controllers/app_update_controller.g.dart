// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_update_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AppUpdateController)
const appUpdateControllerProvider = AppUpdateControllerProvider._();

final class AppUpdateControllerProvider
    extends $NotifierProvider<AppUpdateController, AppUpdateState> {
  const AppUpdateControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appUpdateControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appUpdateControllerHash();

  @$internal
  @override
  AppUpdateController create() => AppUpdateController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppUpdateState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppUpdateState>(value),
    );
  }
}

String _$appUpdateControllerHash() =>
    r'a5e88405f1bebf1c7e0cbe78eca2e7126995ef5e';

abstract class _$AppUpdateController extends $Notifier<AppUpdateState> {
  AppUpdateState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AppUpdateState, AppUpdateState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppUpdateState, AppUpdateState>,
              AppUpdateState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
