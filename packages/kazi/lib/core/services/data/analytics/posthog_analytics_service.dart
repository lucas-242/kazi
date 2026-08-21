import 'package:kazi/core/services/data/analytics/analytics_scrubber.dart';
import 'package:kazi/core/services/domain/analytics_event.dart';
import 'package:kazi/core/services/domain/analytics_service.dart';
import 'package:kazi/core/services/domain/crashlytics_service.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;
import 'package:posthog_flutter/posthog_flutter.dart';

/// The PostHog sink. Receives the whole taxonomy, plus session replay.
final class PostHogAnalyticsService implements AnalyticsService {
  PostHogAnalyticsService(this._posthog, this._crashlyticsService);

  final Posthog _posthog;
  final CrashlyticsService _crashlyticsService;

  /// Called once from `main`, before the first frame.
  ///
  /// Comes up opted out and stays silent until [AnalyticsBootstrap] has read
  /// the consent flags. Starting hot and switching off later would leak a first
  /// session from someone who had said no.
  Future<void> setup({
    required String projectToken,
    required String host,
    required bool debug,
  }) async {
    if (projectToken.isEmpty) {
      // The `.env.*` files are gitignored, so a missing key is a setup mistake,
      // never a reason to fail the launch.
      Log.error('POSTHOG_API_KEY is empty; PostHog will not be initialised.');
      return;
    }

    try {
      final config = PostHogConfig(projectToken)
        ..host = host
        ..debug = debug
        ..optOut = true
        ..captureApplicationLifecycleEvents = true
        // Prepared, not started: [AnalyticsBootstrap] decides per session.
        ..sessionReplay = true
        // So a signed-out visitor never accumulates a profile of their own.
        ..personProfiles = PostHogPersonProfiles.identifiedOnly
        ..beforeSend = [_scrub];

      // Already the SDK defaults. Written down so nobody flips one without
      // noticing that a money app depends on them.
      config.sessionReplayConfig
        ..maskAllTexts = true
        ..maskAllImages = true
        ..maskAllPlatformViews = true;

      await _posthog.setup(config);
    } catch (exception, trace) {
      Log.error(exception);
      _crashlyticsService.log(exception, trace);
    }
  }

  /// Covers Dart-captured events only — `\$snapshot`, lifecycle and `\$set` come
  /// straight from the native SDK, which is why replay is fully masked and
  /// person properties are scrubbed at the call site too.
  static PostHogEvent? _scrub(PostHogEvent event) {
    final properties = event.properties;
    if (properties != null) {
      event.properties = AnalyticsScrubber.scrub(properties);
    }
    final userProperties = event.userProperties;
    if (userProperties != null) {
      event.userProperties = AnalyticsScrubber.scrub(userProperties);
    }
    return event;
  }

  @override
  Future<void> log(
    AnalyticsEvent event, {
    Map<String, Object> parameters = const {},
  }) => _guard(
    () => _posthog.capture(
      eventName: event.name,
      properties: parameters.isEmpty ? null : parameters,
    ),
  );

  @override
  Future<void> screen(
    String name, {
    Map<String, Object> parameters = const {},
  }) => _guard(
    () => _posthog.screen(
      screenName: name,
      properties: parameters.isEmpty ? null : parameters,
    ),
  );

  @override
  Future<void> identify(
    String userId, {
    Map<String, Object> properties = const {},
  }) => _guard(
    () => _posthog.identify(
      userId: userId,
      userProperties: properties.isEmpty
          ? null
          : AnalyticsScrubber.scrub(properties),
    ),
  );

  @override
  Future<void> setUserProperties(Map<String, Object> properties) {
    if (properties.isEmpty) return Future.value();
    return _guard(
      () => _posthog.setPersonProperties(
        userPropertiesToSet: AnalyticsScrubber.scrub(properties),
      ),
    );
  }

  @override
  Future<void> reset() => _guard(_posthog.reset);

  /// Must be called before any replay method: `startSessionRecording` is inert
  /// while the SDK is opted out.
  Future<void> setCollectionEnabled(bool enabled) =>
      _guard(() => enabled ? _posthog.enable() : _posthog.disable());

  /// [restart] serves the friction trigger, which needs a recording that starts
  /// now rather than one resuming a session already discarded.
  Future<void> startReplay({bool restart = false}) =>
      _guard(() => _posthog.startSessionRecording(resumeCurrent: !restart));

  Future<void> stopReplay() => _guard(_posthog.stopSessionRecording);

  Future<void> _guard(Future<void> Function() call) async {
    try {
      await call();
    } catch (exception, trace) {
      Log.error(exception);
      _crashlyticsService.log(exception, trace);
    }
  }
}
