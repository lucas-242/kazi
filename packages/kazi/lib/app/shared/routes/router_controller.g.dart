// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RouterController)
const routerControllerProvider = RouterControllerProvider._();

final class RouterControllerProvider
    extends $AsyncNotifierProvider<RouterController, bool> {
  const RouterControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routerControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routerControllerHash();

  @$internal
  @override
  RouterController create() => RouterController();
}

String _$routerControllerHash() => r'240fbdfbc263a286448bc92f469cced5176acd2d';

abstract class _$RouterController extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
