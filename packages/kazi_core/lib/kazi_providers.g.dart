// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kazi_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(localStorage)
const localStorageProvider = LocalStorageProvider._();

final class LocalStorageProvider extends $FunctionalProvider<
        AsyncValue<KaziLocalStorageService>,
        KaziLocalStorageService,
        FutureOr<KaziLocalStorageService>>
    with
        $FutureModifier<KaziLocalStorageService>,
        $FutureProvider<KaziLocalStorageService> {
  const LocalStorageProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'localStorageProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$localStorageHash();

  @$internal
  @override
  $FutureProviderElement<KaziLocalStorageService> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<KaziLocalStorageService> create(Ref ref) {
    return localStorage(ref);
  }
}

String _$localStorageHash() => r'a22887f29baabfce0f5b947d0bac310e38bbdbcf';

@ProviderFor(inAppReviewService)
const inAppReviewServiceProvider = InAppReviewServiceProvider._();

final class InAppReviewServiceProvider extends $FunctionalProvider<
    KaziInAppReviewService,
    KaziInAppReviewService,
    KaziInAppReviewService> with $Provider<KaziInAppReviewService> {
  const InAppReviewServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'inAppReviewServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$inAppReviewServiceHash();

  @$internal
  @override
  $ProviderElement<KaziInAppReviewService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  KaziInAppReviewService create(Ref ref) {
    return inAppReviewService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KaziInAppReviewService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KaziInAppReviewService>(value),
    );
  }
}

String _$inAppReviewServiceHash() =>
    r'cbdad94529cdec0025b320f7461ea57964836b4a';

@ProviderFor(inAppReviewManager)
const inAppReviewManagerProvider = InAppReviewManagerProvider._();

final class InAppReviewManagerProvider extends $FunctionalProvider<
        AsyncValue<KaziInAppReviewManager>,
        KaziInAppReviewManager,
        FutureOr<KaziInAppReviewManager>>
    with
        $FutureModifier<KaziInAppReviewManager>,
        $FutureProvider<KaziInAppReviewManager> {
  const InAppReviewManagerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'inAppReviewManagerProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$inAppReviewManagerHash();

  @$internal
  @override
  $FutureProviderElement<KaziInAppReviewManager> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<KaziInAppReviewManager> create(Ref ref) {
    return inAppReviewManager(ref);
  }
}

String _$inAppReviewManagerHash() =>
    r'4c6b2d65bae3d3c143be70618b7fb9ecaa274f23';

@ProviderFor(usersRepository)
const usersRepositoryProvider = UsersRepositoryProvider._();

final class UsersRepositoryProvider
    extends $FunctionalProvider<UserRepository, UserRepository, UserRepository>
    with $Provider<UserRepository> {
  const UsersRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'usersRepositoryProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$usersRepositoryHash();

  @$internal
  @override
  $ProviderElement<UserRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  UserRepository create(Ref ref) {
    return usersRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserRepository>(value),
    );
  }
}

String _$usersRepositoryHash() => r'48f837b62b5caa0cfac64728cc5514ddcf5c4354';

@ProviderFor(serviceTypeRepositoy)
const serviceTypeRepositoyProvider = ServiceTypeRepositoyProvider._();

final class ServiceTypeRepositoyProvider extends $FunctionalProvider<
    ServiceTypeRepository,
    ServiceTypeRepository,
    ServiceTypeRepository> with $Provider<ServiceTypeRepository> {
  const ServiceTypeRepositoyProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'serviceTypeRepositoyProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$serviceTypeRepositoyHash();

  @$internal
  @override
  $ProviderElement<ServiceTypeRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ServiceTypeRepository create(Ref ref) {
    return serviceTypeRepositoy(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ServiceTypeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ServiceTypeRepository>(value),
    );
  }
}

String _$serviceTypeRepositoyHash() =>
    r'2e21e43f96282a6da16d69a80836f06eb60e7512';
