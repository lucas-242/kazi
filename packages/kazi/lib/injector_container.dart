import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kazi/core/services/domain/crashlytics_service.dart';
import 'package:kazi/core/services/data/firebase_crashlytics_service.dart';
import 'package:kazi/features/services/domain/services/services_service.dart';
import 'package:kazi/core/services/data/local_time_service.dart';
import 'package:kazi/core/environment/environment.dart';
import 'package:kazi/core/environment/firebase_wrapper.dart';
import 'package:kazi/features/services/data/repositories/firebase_service_type_repository.dart';
import 'package:kazi/features/services/domain/repositories/service_type_repository.dart';
import 'package:kazi/features/services/data/repositories/firebase_services_repository.dart';
import 'package:kazi/features/services/domain/repositories/services_repository.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/auth/data/services/firebase_auth_service.dart';
import 'package:kazi/features/services/data/services/local_services_service.dart';
import 'package:kazi/core/services/domain/time_service.dart';

final serviceLocator = GetIt.instance;

abstract class InjectorContainer {
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) {
      return;
    }

    await Environment.load();
    await _initGoogle();
    _initServices();
    _initRepositories();

    _isInitialized = true;
  }

  static void reset() {
    _isInitialized = false;
    serviceLocator.reset();
  }

  static Future<void> _initGoogle() async {
    await FirebaseWrapper.initialize();

    await MobileAds.instance.initialize();

    serviceLocator.registerLazySingleton<CrashlyticsService>(
      () => FirebaseCrashlyticsService(FirebaseCrashlytics.instance),
    );
    serviceLocator.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance,
    );

    await serviceLocator.get<CrashlyticsService>().init();
  }

  static void _initServices() {
    serviceLocator.registerLazySingleton<AuthService>(
      () => FirebaseAuthService(
        crashlyticsService: serviceLocator.get<CrashlyticsService>(),
      ),
    );
    serviceLocator.registerLazySingleton<TimeService>(() => LocalTimeService());
    serviceLocator.registerLazySingleton<ServicesService>(
      () => LocalServicesService(serviceLocator.get<TimeService>()),
    );
  }

  static void _initRepositories() {
    serviceLocator.registerFactory<ServicesRepository>(
      () => FirebaseServicesRepository(
        serviceLocator.get<FirebaseFirestore>(),
        serviceLocator.get<CrashlyticsService>(),
      ),
    );
    serviceLocator.registerFactory<ServiceTypeRepository>(
      () => FirebaseServiceTypeRepository(
        serviceLocator.get<FirebaseFirestore>(),
        serviceLocator.get<CrashlyticsService>(),
      ),
    );
  }
}
