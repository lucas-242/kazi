import 'package:kazi_core/modules/services/data/api_service_type_repository.dart';
import 'package:kazi_core/modules/services/domain/repositories/service_type_repository.dart';
import 'package:kazi_core/modules/users/data/api_user_repository.dart';
import 'package:kazi_core/modules/users/domain/repositories/user_repository.dart';
import 'package:kazi_core/shared/services/in_app_review/kazi_in_app_review_manager.dart';
import 'package:kazi_core/shared/services/in_app_review/kazi_in_app_review_service.dart';
import 'package:kazi_core/shared/services/in_app_review/kazi_in_app_review_service_impl.dart';
import 'package:kazi_core/shared/services/local_storage/kazi_local_storage_service.dart';
import 'package:kazi_core/shared/services/local_storage/shared_preferences_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'kazi_providers.g.dart';

@riverpod
Future<KaziLocalStorageService> localStorage(Ref ref) async =>
    SharedPreferencesImpl.createInstance();

@riverpod
KaziInAppReviewService inAppReviewService(Ref ref) =>
    KaziInAppReviewServiceImpl();

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
