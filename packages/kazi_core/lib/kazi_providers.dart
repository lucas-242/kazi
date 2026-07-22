import 'package:kazi_core/modules/currency/data/api_exchange_rate_repository.dart';
import 'package:kazi_core/modules/currency/domain/models/exchange_rates.dart';
import 'package:kazi_core/modules/currency/domain/repositories/exchange_rate_repository.dart';
import 'package:kazi_core/modules/services/data/api_service_type_repository.dart';
import 'package:kazi_core/modules/services/domain/repositories/service_type_repository.dart';
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
ServiceTypeRepository serviceTypeRepositoy(Ref ref) =>
    ApiServiceTypeRepository();

@Riverpod()
ExchangeRateRepository exchangeRateRepository(Ref ref) =>
    ApiExchangeRateRepository();

/// Latest exchange rates, cached for the app session. Kept alive so a snapshot
/// is reused across creations without re-fetching on every save.
@Riverpod(keepAlive: true)
Future<ExchangeRates> exchangeRates(Ref ref) =>
    ref.watch(exchangeRateRepositoryProvider).getRates();
