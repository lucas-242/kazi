abstract class AppError implements Exception {
  AppError(this.message, {this.trace, this.cause});
  String message;

  /// Where [cause] was caught, when there is one; otherwise where this was
  /// thrown, when the thrower had it.
  StackTrace? trace;

  /// The failure this error translates for the user — a `FirebaseException`,
  /// a `PlatformException`, or another [AppError]. Null when the error
  /// originates here.
  final Object? cause;

  @override
  String toString() => message;
}

class ExternalError extends AppError {
  ExternalError(super.message, {super.trace, super.cause});
}

class TimeoutError extends ExternalError {
  TimeoutError(super.message, {super.trace, super.cause});
}

class ClientError extends AppError {
  ClientError(super.message, {super.trace, super.cause});
}
