import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:kazi/core/routes/current_screen.dart';
import 'package:kazi/core/services/domain/analytics_event.dart';
import 'package:kazi/core/services/domain/error_kind.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

typedef ProviderReader = T Function<T>(ProviderListenable<T> provider);

/// Records that an error was put in front of the user — in analytics, in
/// Crashlytics, and in the friction detector.
///
/// `BaseNotifier` calls it for every controller; a widget that shows an error
/// itself must call it too, or that error reaches neither Crashlytics nor
/// analytics. [origin] names the class that showed it. Takes `ref.read`, so it
/// serves both a `Ref` and a `WidgetRef`.
void reportShownError(
  ProviderReader read,
  Object exception,
  StackTrace? trace, {
  required String origin,
}) {
  // The class, never the message: the message is localized, so grouping on it
  // would split one problem across three languages, and it can quote what the
  // user typed.
  final code = exception.runtimeType.toString();
  final screen = currentScreenName(() => read(kaziRouterProvider));
  final root = _rootOf(exception, trace);

  // The root cause, not the wrapper: a repository already reported it where
  // it caught it, and the service ignores a second report of the same one.
  _guarded(
    () => read(crashlyticsServiceProvider).log(
      root.error,
      root.trace ?? StackTrace.current,
      reason: '$code shown by $origin on $screen',
    ),
  );

  _guarded(
    () => unawaited(
      read(analyticsServiceProvider).log(
        AnalyticsEvent.errorShown,
        parameters: {
          'code': code,
          'screen': screen,
          'origin': origin,
          'kind': ErrorKind.of(root.error).value,
          if (!identical(root.error, exception)) 'cause': _describe(root.error),
        },
      ),
    ),
  );

  _guarded(
    () => read(frictionDetectorProvider).onError(code: code, screen: screen),
  );
}

/// Each destination on its own, and never throwing: this runs on the failure
/// path of every screen, so resolving a provider — not just calling it — must
/// be unable to turn a handled error into an unhandled one, or to cost the
/// other destinations their report.
void _guarded(void Function() report) {
  try {
    report();
  } catch (reportFailure) {
    Log.error('Failed to report error: $reportFailure');
  }
}

/// Reports to Crashlytics a failure the app recovered from without telling the
/// user — a fallback taken, a default used. Never throws, so it is safe inside
/// the `catch` that takes the fallback.
void reportRecoveredError(
  ProviderReader read,
  Object error,
  StackTrace trace,
) => _guarded(() => read(crashlyticsServiceProvider).log(error, trace));

/// The innermost failure behind an error, and the deepest trace on the way to
/// it — where it was caught, not where it was translated.
({Object error, StackTrace? trace}) _rootOf(
  Object exception,
  StackTrace? trace,
) {
  var error = exception;
  var deepest = trace;
  while (error is AppError) {
    deepest = error.trace ?? deepest;
    final cause = error.cause;
    if (cause == null) break;
    error = cause;
  }
  return (error: error, trace: deepest);
}

/// Plugin and code for the platform failures, which name the actual problem
/// (`cloud_firestore/unavailable`); the class for anything else.
String _describe(Object cause) => switch (cause) {
  FirebaseException(:final plugin, :final code) => '$plugin/$code',
  PlatformException(:final code) => 'PlatformException/$code',
  _ => cause.runtimeType.toString(),
};
