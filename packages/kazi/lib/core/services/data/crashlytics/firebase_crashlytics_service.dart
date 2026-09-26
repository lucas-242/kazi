import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:kazi/core/services/domain/crashlytics_service.dart';

final class FirebaseCrashlyticsService implements CrashlyticsService {
  FirebaseCrashlyticsService(this._crashlytics, {bool? isCollectionEnabled})
    : _isCollectionEnabled = isCollectionEnabled ?? !kDebugMode;

  final FirebaseCrashlytics _crashlytics;

  /// Off in debug: a crash on a developer's machine is noise in the dashboard,
  /// and `prod` and `prod_test` share one Firebase project, so there is no
  /// separate bucket for it to land in.
  final bool _isCollectionEnabled;

  @override
  Future<void> init() async {
    await _crashlytics.setCrashlyticsCollectionEnabled(_isCollectionEnabled);

    // Left alone in debug on purpose: overriding them would hand the error to
    // a disabled collector, which drops it instead of printing it — the
    // console output is the whole point of a debug run.
    if (!_isCollectionEnabled) return;

    FlutterError.onError = (errorDetails) {
      _crashlytics.recordFlutterFatalError(errorDetails);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }

  @override
  void log(Object exception, StackTrace stackTrace) =>
      _crashlytics.recordError(exception, stackTrace);

  @override
  Future<void> setUser(String? userId) =>
      _crashlytics.setUserIdentifier(userId ?? '');

  @override
  Future<void> setCustomKey(String key, Object value) =>
      _crashlytics.setCustomKey(key, value);
}
