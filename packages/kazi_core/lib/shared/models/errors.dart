/// How a failure should be read when it is reported.
///
/// Follows Dart's own split: an [Exception] is a condition the app has to
/// expect, an [Error] is a bug. See `errors.md`.
enum ErrorKind {
  /// A rule refused what the user asked — a repeated document, a missing field.
  businessRule('business_rule'),

  /// Something outside the app failed — the network, Firestore, the store.
  external('external'),

  /// A bug.
  unexpected('unexpected');

  const ErrorKind(this.value);

  /// The wire value, identical in Crashlytics and analytics.
  final String value;

  /// A bug anywhere in the cause chain wins: wrapping one in an external
  /// failure must not hide it.
  static ErrorKind of(Object error) {
    if (rootCauseOf(error).error is Error) return unexpected;
    return error is AppError ? error.kind : external;
  }
}

/// One way a module can fail. Implemented by an enum per module, whose value
/// name becomes the second half of [AppError.code] — renaming one splits its
/// history in every report.
abstract interface class Failure implements Enum {
  /// Shown to the user; localized, so read when the error is thrown.
  String get message;

  ErrorKind get kind;
}

abstract class AppError implements Exception {
  AppError(String? message, {this.trace, this.cause}) : _message = message;

  final String? _message;

  /// Shown to the user; localized.
  String get message => _message ?? '';

  /// Where [cause] was caught, when there is one; otherwise where this was
  /// thrown, when the thrower had it.
  StackTrace? trace;

  /// The failure this error translates for the user — a `FirebaseException`,
  /// a `PlatformException`, or another [AppError]. Null when the error
  /// originates here.
  final Object? cause;

  /// What failed, as `<module>/<failure>` (`services/add`). Stable across
  /// languages and class renames, unlike [message] and `runtimeType`.
  String get code;

  ErrorKind get kind;

  @override
  String toString() => message;
}

/// The error a module throws: one subclass per module, one [Failure] value
/// per thing that can go wrong in it.
abstract class ModuleError<F extends Failure> extends AppError {
  ModuleError(this.failure, {String? message, super.cause, super.trace})
      : super(message);

  final F failure;

  /// Resolved when read, not when thrown: an error raised before the
  /// localizations load must still construct — and still print, as its code.
  @override
  String get message {
    if (_message case final String given) return given;
    try {
      return failure.message;
    } on Error {
      return code;
    }
  }

  /// The first half of [code], in lower snake case.
  String get module;

  @override
  String get code => '$module/${failure.name}';

  @override
  ErrorKind get kind => failure.kind;
}

/// The innermost failure behind [error], following [AppError.cause], and the
/// deepest trace on the way to it — where it was caught, not where it was
/// translated.
({Object error, StackTrace? trace}) rootCauseOf(
  Object error, [
  StackTrace? trace,
]) {
  var current = error;
  var deepest = trace;
  while (current is AppError) {
    deepest = current.trace ?? deepest;
    final cause = current.cause;
    if (cause == null) break;
    current = cause;
  }
  return (error: current, trace: deepest);
}
