// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AppController)
const appControllerProvider = AppControllerProvider._();

final class AppControllerProvider
    extends $NotifierProvider<AppController, AppPages> {
  const AppControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'appControllerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$appControllerHash();

  @$internal
  @override
  AppController create() => AppController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppPages value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppPages>(value),
    );
  }
}

String _$appControllerHash() => r'55ef11de82c58b22835a456ce56349168439d2b0';

abstract class _$AppController extends $Notifier<AppPages> {
  AppPages build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AppPages, AppPages>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AppPages, AppPages>, AppPages, Object?, Object?>;
    element.handleValue(ref, created);
  }
}
