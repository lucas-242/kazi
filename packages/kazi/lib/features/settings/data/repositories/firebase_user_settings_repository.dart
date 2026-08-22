import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:kazi/core/services/domain/crashlytics_service.dart';
import 'package:kazi/features/settings/domain/models/billing_cycle.dart';
import 'package:kazi/features/settings/domain/models/user_settings.dart';
import 'package:kazi/features/settings/domain/repositories/user_settings_repository.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

class FirebaseUserSettingsRepository implements UserSettingsRepository {
  FirebaseUserSettingsRepository(
    FirebaseFirestore firestore,
    this._crashlyticsService,
  ) : _firestore = firestore;

  final FirebaseFirestore _firestore;
  final CrashlyticsService _crashlyticsService;

  static const String _setupCompletedField = 'setupCompletedAt';
  static const String _setupSkippedField = 'setupSkippedAt';
  static const String _professionField = 'profession';
  static const String _onboardingStepsField = 'onboardingSteps';

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
      final setupCompletedAt = data[_setupCompletedField];
      final setupSkippedAt = data[_setupSkippedField];
      final profession = data[_professionField];
      final steps = data[_onboardingStepsField];

      return UserSettings(
        defaultCurrency: currency is String && currency.isNotEmpty
            ? SupportedCurrency.fromCode(currency)
            : null,
        currencyMigratedAt: migratedAt is Timestamp
            ? migratedAt.toDate()
            : null,
        migratedServices: (data['migratedServices'] as num?)?.toInt() ?? 0,
        // Reads its own two fields off the document and degrades to the
        // default rather than throwing, so a corrupt value cannot lock a user
        // out of their own totals.
        billingCycle: BillingCycle.fromMap(data),
        // Same discipline for the onboarding fields: a corrupt value must read
        // as "not set" and let the user through, never throw. The worst case
        // is being asked once more, which is recoverable; being locked out of
        // the app is not.
        setupCompletedAt: setupCompletedAt is Timestamp
            ? setupCompletedAt.toDate()
            : null,
        setupSkippedAt: setupSkippedAt is Timestamp
            ? setupSkippedAt.toDate()
            : null,
        profession: profession is String && profession.isNotEmpty
            ? profession
            : null,
        completedOnboardingSteps: steps is Map
            ? steps.keys.whereType<String>().toSet()
            : const {},
        // Presence of the field, not its value: `BillingCycle.fromMap` above
        // answers monthly for a document that never mentioned a cycle.
        hasExplicitBillingCycle: data.containsKey(BillingCycle.typeField),
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
  ) => _merge(userId, {'defaultCurrency': currency.isoCode});

  @override
  Future<void> setBillingCycle(String userId, BillingCycle cycle) =>
      _merge(userId, cycle.toMap());

  @override
  Future<void> markCurrencyMigrated(String userId, {required int migrated}) =>
      _merge(userId, {
        'currencyMigratedAt': FieldValue.serverTimestamp(),
        'migratedServices': migrated,
      });

  @override
  Future<void> setProfession(String userId, String profession) =>
      _merge(userId, {_professionField: profession});

  @override
  Future<void> markSetupCompleted(String userId) =>
      _merge(userId, {_setupCompletedField: FieldValue.serverTimestamp()});

  @override
  Future<void> markSetupSkipped(String userId) =>
      _merge(userId, {_setupSkippedField: FieldValue.serverTimestamp()});

  @override
  Future<void> markOnboardingStep(String userId, String step) => _merge(userId, {
    // A nested map is safe here: `SetOptions(merge: true)` merges map values
    // recursively, so the steps already recorded survive. A dotted key would
    // not — `set` reads keys literally, and only `update` treats them as paths.
    _onboardingStepsField: {step: FieldValue.serverTimestamp()},
  });

  @override
  Future<void> resetOnboardingForDebug(String userId) => _merge(userId, {
    _setupCompletedField: FieldValue.delete(),
    _setupSkippedField: FieldValue.delete(),
    _professionField: FieldValue.delete(),
    _onboardingStepsField: FieldValue.delete(),
  });

  /// Every write on this document is the same merge into `users/{uid}`, and
  /// they all fail the same way — the user could not save a preference.
  Future<void> _merge(String userId, Map<String, dynamic> data) async {
    try {
      await _firestore
          .collection(path)
          .doc(userId)
          .set(data, SetOptions(merge: true));
    } catch (exception, trace) {
      Log.error(exception);
      _crashlyticsService.log(exception, trace);
      throw ExternalError(KaziLocalizations.current.errorToSaveUserSettings);
    }
  }
}
