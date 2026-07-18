import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:kazi/core/services/data/firebase_crashlytics_service.dart';
import 'package:kazi/core/services/data/local_time_service.dart';
import 'package:kazi/core/services/domain/crashlytics_service.dart';
import 'package:kazi/core/services/domain/time_service.dart';
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
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'injector.g.dart';

// App-level dependency injection wired with Riverpod (replaces get_it).
// All providers are keepAlive so they behave like the previous singletons.

@Riverpod(keepAlive: true)
FirebaseFirestore firebaseFirestore(Ref ref) => FirebaseFirestore.instance;

@Riverpod(keepAlive: true)
CrashlyticsService crashlyticsService(Ref ref) =>
    FirebaseCrashlyticsService(FirebaseCrashlytics.instance);

@Riverpod(keepAlive: true)
TimeService timeService(Ref ref) => LocalTimeService();

@Riverpod(keepAlive: true)
ServicesService servicesService(Ref ref) =>
    LocalServicesService(ref.watch(timeServiceProvider));

@Riverpod(keepAlive: true)
AuthService authService(Ref ref) => FirebaseAuthService(
  crashlyticsService: ref.watch(crashlyticsServiceProvider),
);

@Riverpod(keepAlive: true)
ServicesRepository servicesRepository(Ref ref) => FirebaseServicesRepository(
  ref.watch(firebaseFirestoreProvider),
  ref.watch(crashlyticsServiceProvider),
);

@Riverpod(keepAlive: true)
ClientsRepository clientsRepository(Ref ref) => FirebaseClientsRepository(
  ref.watch(firebaseFirestoreProvider),
  ref.watch(crashlyticsServiceProvider),
);

@Riverpod(keepAlive: true)
ServiceTypeRepository serviceTypeRepository(Ref ref) =>
    FirebaseServiceTypeRepository(
      ref.watch(firebaseFirestoreProvider),
      ref.watch(crashlyticsServiceProvider),
    );
