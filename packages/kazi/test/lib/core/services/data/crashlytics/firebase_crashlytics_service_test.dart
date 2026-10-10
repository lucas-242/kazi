import 'dart:ui' show ErrorCallback;

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/services/data/crashlytics/firebase_crashlytics_service.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

class _FakeFirebaseCrashlytics implements FirebaseCrashlytics {
  bool? collectionEnabled;
  String? userIdentifier;
  final Map<String, Object> customKeys = {};
  final List<Object> recordedErrors = [];
  final List<bool> recordedFatality = [];
  final List<Object?> recordedReasons = [];

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
    recordedFatality.add(fatal);
    recordedReasons.add(reason);
  }

  @override
  Future<void> recordFlutterError(
    FlutterErrorDetails flutterErrorDetails, {
    bool fatal = false,
  }) async {
    recordedErrors.add(flutterErrorDetails.exception);
    recordedFatality.add(fatal);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _ThrowsInBuild extends StatelessWidget {
  const _ThrowsInBuild();

  @override
  Widget build(BuildContext context) => throw Exception('build failed');
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
    late ErrorCallback? originalPlatformOnError;

    setUp(() {
      originalOnError = FlutterError.onError;
      originalPlatformOnError = PlatformDispatcher.instance.onError;
    });
    tearDown(() {
      FlutterError.onError = originalOnError;
      PlatformDispatcher.instance.onError = originalPlatformOnError;
    });

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

    test('reports a widget-tree error as fatal', () async {
      await build(isCollectionEnabled: true).init();

      FlutterError.onError!(
        FlutterErrorDetails(
          exception: Exception('build failed'),
          library: 'widgets library',
        ),
      );

      expect(firebase.recordedFatality, [true]);
    });

    test('reports any other framework error as non-fatal', () async {
      await build(isCollectionEnabled: true).init();

      for (final library in [
        'image resource service',
        'rendering library',
        null,
      ]) {
        FlutterError.onError!(
          FlutterErrorDetails(exception: Exception('failed'), library: library),
        );
      }

      expect(firebase.recordedFatality, [false, false, false]);
    });

    test('reports an uncaught asynchronous error as fatal', () async {
      await build(isCollectionEnabled: true).init();
      final exception = Exception('uncaught');

      PlatformDispatcher.instance.onError!(exception, StackTrace.current);

      expect(firebase.recordedErrors, [exception]);
      expect(firebase.recordedFatality, [true]);
    });
  });

  testWidgets('Flutter labels a build failure as the service expects', (
    tester,
  ) async {
    final testHandler = FlutterError.onError;
    FlutterErrorDetails? reported;
    FlutterError.onError = (details) => reported = details;

    await tester.pumpWidget(const _ThrowsInBuild());
    FlutterError.onError = testHandler;

    expect(reported?.library, 'widgets library');
  });

  test('defaults collection to off in debug', () async {
    await FirebaseCrashlyticsService(firebase).init();

    expect(firebase.collectionEnabled, !kDebugMode);
  });

  group('handled errors', () {
    test('are reported as non-fatal, with the reason', () {
      final exception = Exception('boom');

      build(
        isCollectionEnabled: true,
      ).log(exception, StackTrace.current, reason: 'shown on home');

      expect(firebase.recordedErrors, [exception]);
      expect(firebase.recordedFatality, [false]);
      expect(firebase.recordedReasons, ['shown on home']);
    });

    test('are reported once, however many layers log them', () {
      final service = build(isCollectionEnabled: true);
      final exception = Exception('boom');

      service
        ..log(exception, StackTrace.current)
        ..log(exception, StackTrace.current, reason: 'shown on home');

      expect(firebase.recordedErrors, [exception]);
    });

    test('that cannot be tracked are always reported', () {
      build(isCollectionEnabled: true)
        ..log('boom', StackTrace.current)
        ..log('boom', StackTrace.current);

      expect(firebase.recordedErrors, ['boom', 'boom']);
    });

    test('are tagged with their kind', () {
      final service = build(isCollectionEnabled: true);

      service.log(ClientError('repeated document'), StackTrace.current);
      expect(firebase.customKeys['error_kind'], 'business_rule');

      service.log(Exception('offline'), StackTrace.current);
      expect(firebase.customKeys['error_kind'], 'external');

      service.log(StateError('bug'), StackTrace.current);
      expect(firebase.customKeys['error_kind'], 'unexpected');
    });
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
