import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:kazi/core/services/domain/crashlytics_service.dart';
import 'package:kazi/features/settings/domain/models/user_settings.dart';
import 'package:kazi/features/settings/domain/repositories/user_settings_repository.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

class FirebaseUserSettingsRepository implements UserSettingsRepository {
  FirebaseUserSettingsRepository(
    FirebaseFirestore firestore,
    this._crashlyticsService,
  ) : _firestore = firestore;

  final FirebaseFirestore _firestore;
  final CrashlyticsService _crashlyticsService;

  @visibleForTesting
  String get path => 'users';

  @override
  Future<UserSettings> get(String userId) async {
    try {
      final snapshot = await _firestore.collection(path).doc(userId).get();
      final data = snapshot.data();

      if (data == null) return const UserSettings();

      final migratedAt = data['currencyMigratedAt'];
      final currency = data['defaultCurrency'];

      return UserSettings(
        defaultCurrency: currency is String && currency.isNotEmpty
            ? SupportedCurrency.fromCode(currency)
            : null,
        currencyMigratedAt: migratedAt is Timestamp ? migratedAt.toDate() : null,
        migratedServices: (data['migratedServices'] as num?)?.toInt() ?? 0,
      );
    } catch (exception, trace) {
      Log.error(exception);
      _crashlyticsService.log(exception, trace);
      throw ExternalError(KaziLocalizations.current.errorToGetUserSettings);
    }
  }

  @override
  Future<void> setDefaultCurrency(
    String userId,
    SupportedCurrency currency,
  ) async {
    try {
      await _firestore.collection(path).doc(userId).set(
        {'defaultCurrency': currency.isoCode},
        SetOptions(merge: true),
      );
    } catch (exception, trace) {
      Log.error(exception);
      _crashlyticsService.log(exception, trace);
      throw ExternalError(KaziLocalizations.current.errorToSaveUserSettings);
    }
  }

  @override
  Future<void> markCurrencyMigrated(
    String userId, {
    required int migrated,
  }) async {
    try {
      await _firestore.collection(path).doc(userId).set(
        {
          'currencyMigratedAt': FieldValue.serverTimestamp(),
          'migratedServices': migrated,
        },
        SetOptions(merge: true),
      );
    } catch (exception, trace) {
      Log.error(exception);
      _crashlyticsService.log(exception, trace);
      throw ExternalError(KaziLocalizations.current.errorToSaveUserSettings);
    }
  }
}
