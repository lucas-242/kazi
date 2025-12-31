import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kazi/app/services/crashlytics_service/crashlytics_service.dart';
import 'package:kazi/app/services/crashlytics_service/firebase/firebase_crashlytics_service.dart';
import 'package:kazi/app/services/services_service/services_service.dart';
import 'package:kazi/app/services/time_service/local/local_time_service.dart';
import 'package:kazi/app/shared/firebase_wrapper.dart';

import 'app/repositories/service_type_repository/firebase/firebase_service_type_repository.dart';
import 'app/repositories/service_type_repository/service_type_repository.dart';
import 'app/repositories/services_repository/firebase/firebase_services_repository.dart';
import 'app/repositories/services_repository/services_repository.dart';
import 'app/services/auth_service/auth_service.dart';
import 'app/services/auth_service/firebase/firebase_auth_service.dart';
import 'app/services/services_service/local/local_services_service.dart';
import 'app/services/time_service/time_service.dart';

final serviceLocator = GetIt.instance;

abstract class InjectorContainer {
  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) {
      return;
    }

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
    serviceLocator.registerLazySingleton<ServicesRepository>(
      () => FirebaseServicesRepository(
        serviceLocator.get<FirebaseFirestore>(),
        serviceLocator.get<CrashlyticsService>(),
      ),
    );
    serviceLocator.registerLazySingleton<ServiceTypeRepository>(
      () => FirebaseServiceTypeRepository(
        serviceLocator.get<FirebaseFirestore>(),
        serviceLocator.get<CrashlyticsService>(),
      ),
    );
  }
}
