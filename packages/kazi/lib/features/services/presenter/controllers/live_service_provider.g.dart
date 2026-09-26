// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'live_service_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The current version of the service with [id], or null when no list holds it.
///
/// The details page is handed an immutable `Service` through go_router's
/// `extra`, so anything that mutates the service — marking it as received —
/// would leave that page rendering the state from before the tap. Watching this
/// instead makes the page follow whichever list the service came from.
///
/// Both sources are `keepAlive` and their `build()` only assembles a state
/// object, so reading them here cannot trigger a fetch.

@ProviderFor(liveService)
const liveServiceProvider = LiveServiceFamily._();

/// The current version of the service with [id], or null when no list holds it.
///
/// The details page is handed an immutable `Service` through go_router's
/// `extra`, so anything that mutates the service — marking it as received —
/// would leave that page rendering the state from before the tap. Watching this
/// instead makes the page follow whichever list the service came from.
///
/// Both sources are `keepAlive` and their `build()` only assembles a state
/// object, so reading them here cannot trigger a fetch.

final class LiveServiceProvider
    extends $FunctionalProvider<Service?, Service?, Service?>
    with $Provider<Service?> {
  /// The current version of the service with [id], or null when no list holds it.
  ///
  /// The details page is handed an immutable `Service` through go_router's
  /// `extra`, so anything that mutates the service — marking it as received —
  /// would leave that page rendering the state from before the tap. Watching this
  /// instead makes the page follow whichever list the service came from.
  ///
  /// Both sources are `keepAlive` and their `build()` only assembles a state
  /// object, so reading them here cannot trigger a fetch.
  const LiveServiceProvider._({
    required LiveServiceFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'liveServiceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$liveServiceHash();

  @override
  String toString() {
    return r'liveServiceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Service?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Service? create(Ref ref) {
    final argument = this.argument as String;
    return liveService(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Service? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Service?>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LiveServiceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$liveServiceHash() => r'8b85c47807b9b36eae8240c6a3500f313ce071e6';

/// The current version of the service with [id], or null when no list holds it.
///
/// The details page is handed an immutable `Service` through go_router's
/// `extra`, so anything that mutates the service — marking it as received —
/// would leave that page rendering the state from before the tap. Watching this
/// instead makes the page follow whichever list the service came from.
///
/// Both sources are `keepAlive` and their `build()` only assembles a state
/// object, so reading them here cannot trigger a fetch.

final class LiveServiceFamily extends $Family
    with $FunctionalFamilyOverride<Service?, String> {
  const LiveServiceFamily._()
    : super(
        retry: null,
        name: r'liveServiceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The current version of the service with [id], or null when no list holds it.
  ///
  /// The details page is handed an immutable `Service` through go_router's
  /// `extra`, so anything that mutates the service — marking it as received —
  /// would leave that page rendering the state from before the tap. Watching this
  /// instead makes the page follow whichever list the service came from.
  ///
  /// Both sources are `keepAlive` and their `build()` only assembles a state
  /// object, so reading them here cannot trigger a fetch.

  LiveServiceProvider call(String id) =>
      LiveServiceProvider._(argument: id, from: this);

  @override
  String toString() => r'liveServiceProvider';
}
