import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:kazi/core/services/domain/crashlytics_service.dart';
import 'package:kazi/core/services/domain/error_kind.dart';

final class FirebaseCrashlyticsService implements CrashlyticsService {
  FirebaseCrashlyticsService(this._crashlytics, {bool? isCollectionEnabled})
    : _isCollectionEnabled = isCollectionEnabled ?? !kDebugMode;

  final FirebaseCrashlytics _crashlytics;

  /// Off in debug: a crash on a developer's machine is noise in the dashboard,
  /// and `prod` and `prod_test` share one Firebase project, so there is no
  /// separate bucket for it to land in.
  final bool _isCollectionEnabled;

  /// The `library` Flutter stamps on build failures, the ones that leave an
  /// [ErrorWidget] where the screen should be.
  static const _widgetsLibrary = 'widgets library';

  @override
  Future<void> init() async {
    await _crashlytics.setCrashlyticsCollectionEnabled(_isCollectionEnabled);

    // Left alone in debug on purpose: overriding them would hand the error to
    // a disabled collector, which drops it instead of printing it — the
    // console output is the whole point of a debug run.
    if (!_isCollectionEnabled) return;

    // Only widget-tree failures are fatal: on Android a fatal report logs
    // `app_exception` and ends the session. See README.md.
    FlutterError.onError = (errorDetails) {
      _crashlytics.recordFlutterError(
        errorDetails,
        fatal: errorDetails.library == _widgetsLibrary,
      );
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }

  final _reported = Expando<bool>();

  @override
  void log(Object exception, StackTrace stackTrace, {String? reason}) {
    if (_wasReported(exception)) return;

    // Set on every report, so it never carries over from the previous one.
    _crashlytics.setCustomKey(_errorKindKey, ErrorKind.of(exception).value);
    _crashlytics.recordError(exception, stackTrace, reason: reason);
  }

  static const _errorKindKey = 'error_kind';

  /// Marks [exception] as reported, answering whether it already was.
  /// Strings, numbers and records cannot be tracked, and are always reported.
  bool _wasReported(Object exception) {
    if (exception is String ||
        exception is num ||
        exception is bool ||
        exception is Record) {
      return false;
    }
    if (_reported[exception] == true) return true;
    _reported[exception] = true;
    return false;
  }

  @override
  Future<void> setUser(String? userId) =>
      _crashlytics.setUserIdentifier(userId ?? '');

  @override
  Future<void> setCustomKey(String key, Object value) =>
      _crashlytics.setCustomKey(key, value);
}
