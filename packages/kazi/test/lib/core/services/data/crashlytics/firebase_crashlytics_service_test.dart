import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/services/data/crashlytics/firebase_crashlytics_service.dart';

class _FakeFirebaseCrashlytics implements FirebaseCrashlytics {
  bool? collectionEnabled;
  String? userIdentifier;
  final Map<String, Object> customKeys = {};
  final List<Object> recordedErrors = [];

  @override
  Future<void> setCrashlyticsCollectionEnabled(bool enabled) async =>
      collectionEnabled = enabled;

  @override
  Future<void> setUserIdentifier(String identifier) async =>
      userIdentifier = identifier;

  @override
  Future<void> setCustomKey(String key, Object value) async =>
      customKeys[key] = value;

  @override
  Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    dynamic reason,
    Iterable<Object> information = const [],
    bool? printDetails,
    bool fatal = false,
  }) async {
    recordedErrors.add(exception as Object);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeFirebaseCrashlytics firebase;

  setUp(() => firebase = _FakeFirebaseCrashlytics());

  FirebaseCrashlyticsService build({required bool isCollectionEnabled}) =>
      FirebaseCrashlyticsService(
        firebase,
        isCollectionEnabled: isCollectionEnabled,
      );

  group('init', () {
    late FlutterExceptionHandler? originalOnError;

    setUp(() => originalOnError = FlutterError.onError);
    tearDown(() => FlutterError.onError = originalOnError);

    test('enables collection and installs the handler when on', () async {
      await build(isCollectionEnabled: true).init();

      expect(firebase.collectionEnabled, isTrue);
      expect(FlutterError.onError, isNot(originalOnError));
    });

    test('leaves the handlers alone when collection is off', () async {
      await build(isCollectionEnabled: false).init();

      expect(firebase.collectionEnabled, isFalse);
      // Overriding it would hand debug errors to a disabled collector, which
      // drops them instead of printing them to the console.
      expect(FlutterError.onError, originalOnError);
    });
  });

  test('defaults collection to off in debug', () async {
    await FirebaseCrashlyticsService(firebase).init();

    expect(firebase.collectionEnabled, !kDebugMode);
  });

  test('reports a handled error as non-fatal', () {
    final exception = Exception('boom');

    build(isCollectionEnabled: true).log(exception, StackTrace.current);

    expect(firebase.recordedErrors, [exception]);
  });

  group('identity', () {
    test('attributes reports to a user', () async {
      await build(isCollectionEnabled: true).setUser('uid-1');

      expect(firebase.userIdentifier, 'uid-1');
    });

    test('clears the attribution on sign-out', () async {
      await build(isCollectionEnabled: true).setUser(null);

      expect(firebase.userIdentifier, isEmpty);
    });

    test('attaches a custom key', () async {
      await build(isCollectionEnabled: true).setCustomKey('flavor', 'prod');

      expect(firebase.customKeys['flavor'], 'prod');
    });
  });
}
