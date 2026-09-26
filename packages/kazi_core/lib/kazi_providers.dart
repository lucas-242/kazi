import 'package:kazi_core/modules/currency/application/exchange_rate_history_service.dart';
import 'package:kazi_core/modules/currency/data/api_exchange_rate_repository.dart';
import 'package:kazi_core/modules/currency/data/mocks/exchange_rate_mock.dart';
import 'package:kazi_core/modules/currency/domain/models/exchange_rates.dart';
import 'package:kazi_core/modules/currency/domain/repositories/exchange_rate_history_repository.dart';
import 'package:kazi_core/modules/currency/domain/repositories/exchange_rate_repository.dart';
import 'package:kazi_core/modules/services/data/api_catalog_item_repository.dart';
import 'package:kazi_core/modules/services/domain/repositories/catalog_item_repository.dart';
import 'package:kazi_core/modules/users/data/api_user_repository.dart';
import 'package:kazi_core/modules/users/domain/repositories/user_repository.dart';
import 'package:kazi_core/shared/services/app_info/kazi_app_info_service.dart';
import 'package:kazi_core/shared/services/app_info/kazi_app_info_service_impl.dart';
import 'package:kazi_core/shared/services/in_app_review/kazi_in_app_review_manager.dart';
import 'package:kazi_core/shared/services/in_app_review/kazi_in_app_review_service.dart';
import 'package:kazi_core/shared/services/in_app_review/kazi_in_app_review_service_impl.dart';
import 'package:kazi_core/shared/services/local_storage/kazi_local_storage_service.dart';
import 'package:kazi_core/shared/services/local_storage/shared_preferences_impl.dart';
import 'package:kazi_core/shared/services/url_launcher/kazi_url_launcher_service.dart';
import 'package:kazi_core/shared/services/url_launcher/kazi_url_launcher_service_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'kazi_providers.g.dart';

@riverpod
Future<KaziLocalStorageService> localStorage(Ref ref) async =>
    SharedPreferencesImpl.createInstance();

@riverpod
KaziInAppReviewService inAppReviewService(Ref ref) =>
    KaziInAppReviewServiceImpl();

@riverpod
KaziAppInfoService kaziAppInfoService(Ref ref) => KaziAppInfoServiceImpl();

/// The installed version name, for screens that state it rather than act on it.
@riverpod
Future<String> kaziAppVersion(Ref ref) =>
    ref.watch(kaziAppInfoServiceProvider).getVersion();

@riverpod
KaziUrlLauncherService kaziUrlLauncherService(Ref ref) =>
    KaziUrlLauncherServiceImpl();

@riverpod
Future<KaziInAppReviewManager> inAppReviewManager(Ref ref) async =>
    KaziInAppReviewManager(
      storage: await ref.watch(localStorageProvider.future),
      reviewService: ref.watch(inAppReviewServiceProvider),
    );

@riverpod
UserRepository usersRepository(Ref ref) => ApiUserRepository();

@riverpod
CatalogItemRepository catalogItemRepositoy(Ref ref) =>
    ApiCatalogItemRepository();

@riverpod
ExchangeRateRepository exchangeRateRepository(Ref ref) =>
    ApiExchangeRateRepository();

/// Shared store of daily rate snapshots. Overridden per app with a backed
/// implementation (kazi uses Firestore); the in-memory default keeps apps
/// without one working off the API alone.
@riverpod
ExchangeRateHistoryRepository exchangeRateHistoryRepository(Ref ref) =>
    InMemoryExchangeRateHistoryRepository();

/// Resolves rates for any date.
///
/// **Kept alive on purpose:** this object owns the in-memory rate cache, so
/// disposing it would make every screen reload the local-storage cache and
/// re-hit the API. It is also what keeps its two dependencies above alive —
/// they are stateless and need no `keepAlive` of their own.
@Riverpod(keepAlive: true)
Future<ExchangeRateHistoryService> exchangeRateHistoryService(Ref ref) async {
  final history = ref.watch(exchangeRateHistoryRepositoryProvider);
  final api = ref.watch(exchangeRateRepositoryProvider);

  return ExchangeRateHistoryService(
    storage: await ref.watch(localStorageProvider.future),
    history: history,
    api: api,
  );
}

@riverpod
Future<ExchangeRates?> exchangeRates(Ref ref) async =>
    (await ref.watch(exchangeRateHistoryServiceProvider.future)).today();
