import 'dart:async';

import 'package:kazi/core/constants/storage_keys.dart';
import 'package:kazi/features/settings/domain/models/privacy_settings.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

part 'privacy_controller.g.dart';

/// The user's answers about being measured.
///
/// Stored locally rather than on the account document: signing out clears local
/// storage, so the next person on the device is asked for themselves instead of
/// inheriting a stranger's yes.
@Riverpod(keepAlive: true)
class PrivacyController extends _$PrivacyController {
  @override
  FutureOr<PrivacySettings> build() async {
    try {
      final storage = await ref.watch(localStorageProvider.future);
      return PrivacySettings(
        analyticsOptOut:
            await storage.read<bool>(StorageKeys.analyticsOptOut) ?? false,
        sessionReplayConsent: await storage.read<bool>(
          StorageKeys.sessionReplayConsent,
        ),
      );
    } catch (exception) {
      Log.error(exception);
      return const PrivacySettings();
    }
  }

  Future<void> setAnalyticsEnabled(bool enabled) => _update(
    (current) => current.copyWith(analyticsOptOut: !enabled),
    StorageKeys.analyticsOptOut,
    !enabled,
  );

  /// Writing `false` matters as much as `true`: it is what stops the question
  /// being asked again.
  Future<void> setSessionReplayConsent(bool consented) => _update(
    (current) => current.copyWith(sessionReplayConsent: consented),
    StorageKeys.sessionReplayConsent,
    consented,
  );

  /// State first, storage second: a consent toggle that lags behind the finger
  /// reads as broken, and a failed write is recovered by asking again.
  Future<void> _update(
    PrivacySettings Function(PrivacySettings current) next,
    String key,
    bool value,
  ) async {
    final current = state.asData?.value;
    if (current == null) return;

    state = AsyncData(next(current));

    try {
      final storage = await ref.read(localStorageProvider.future);
      await storage.write<bool>(key, value);
    } catch (exception) {
      Log.error(exception);
    }
  }
}

/// Read synchronously by the composite service on every call.
///
/// Defaults to `false` while the store loads: the handful of events in the first
/// milliseconds are worth less than one event sent for somebody who objected.
@Riverpod(keepAlive: true)
bool isAnalyticsAllowed(Ref ref) =>
    ref.watch(privacyControllerProvider).asData?.value.isAnalyticsAllowed ??
    false;

@Riverpod(keepAlive: true)
bool isReplayAllowed(Ref ref) =>
    ref.watch(privacyControllerProvider).asData?.value.isReplayAllowed ?? false;
