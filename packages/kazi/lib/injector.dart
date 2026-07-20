import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:kazi/core/services/data/firebase_crashlytics_service.dart';
import 'package:kazi/core/services/data/local_time_service.dart';
import 'package:kazi/core/services/domain/crashlytics_service.dart';
import 'package:kazi/core/services/domain/time_service.dart';
import 'package:kazi/features/app_update/data/services/remote_config_app_update_service.dart';
import 'package:kazi/features/app_update/domain/services/app_update_service.dart';
import 'package:kazi/features/auth/data/services/firebase_auth_service.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi/features/clients/data/repositories/firebase_clients_repository.dart';
import 'package:kazi/features/clients/domain/repositories/clients_repository.dart';
import 'package:kazi/features/services/data/repositories/firebase_service_type_repository.dart';
import 'package:kazi/features/services/data/repositories/firebase_services_repository.dart';
import 'package:kazi/features/services/data/services/local_services_service.dart';
import 'package:kazi/features/services/domain/repositories/service_type_repository.dart';
import 'package:kazi/features/services/domain/repositories/services_repository.dart';
import 'package:kazi/features/services/domain/services/services_service.dart';
import 'package:kazi_core/kazi_core.dart' hide ServiceTypeRepository;

part 'injector.g.dart';

@Riverpod(keepAlive: true)
FirebaseFirestore firebaseFirestore(Ref ref) => FirebaseFirestore.instance;

@Riverpod(keepAlive: true)
CrashlyticsService crashlyticsService(Ref ref) =>
    FirebaseCrashlyticsService(FirebaseCrashlytics.instance);

@Riverpod()
TimeService timeService(Ref ref) => LocalTimeService();

@Riverpod()
ServicesService servicesService(Ref ref) =>
    LocalServicesService(ref.watch(timeServiceProvider));

@Riverpod(keepAlive: true)
AuthService authService(Ref ref) => FirebaseAuthService(
  crashlyticsService: ref.watch(crashlyticsServiceProvider),
);

@Riverpod()
ServicesRepository servicesRepository(Ref ref) => FirebaseServicesRepository(
  ref.watch(firebaseFirestoreProvider),
  ref.watch(crashlyticsServiceProvider),
);

@Riverpod()
ClientsRepository clientsRepository(Ref ref) => FirebaseClientsRepository(
  ref.watch(firebaseFirestoreProvider),
  ref.watch(crashlyticsServiceProvider),
);

@Riverpod()
ServiceTypeRepository serviceTypeRepository(Ref ref) =>
    FirebaseServiceTypeRepository(
      ref.watch(firebaseFirestoreProvider),
      ref.watch(crashlyticsServiceProvider),
    );

@Riverpod(keepAlive: true)
FirebaseRemoteConfig firebaseRemoteConfig(Ref ref) =>
    FirebaseRemoteConfig.instance;

@Riverpod()
AppUpdateService appUpdateService(Ref ref) => RemoteConfigAppUpdateService(
  ref.watch(firebaseRemoteConfigProvider),
  ref.watch(kaziAppInfoServiceProvider),
  ref.watch(crashlyticsServiceProvider),
);
