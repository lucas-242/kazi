import 'package:flutter_test/flutter_test.dart';
import 'package:kazi_core/kazi_core.dart';

enum _TestFailure implements Failure {
  save,
  duplicateName;

  @override
  String get message => switch (this) {
    save => KaziLocalizations.current.errorUnknowError,
    duplicateName => 'failed: $name',
  };

  @override
  ErrorKind get kind => switch (this) {
    duplicateName => ErrorKind.businessRule,
    save => ErrorKind.external,
  };
}

final class _TestError extends ModuleError<_TestFailure> {
  _TestError(super.failure, {super.message, super.cause, super.trace});

  @override
  String get module => 'test';
}

void main() {
  group('ModuleError', () {
    test('is coded by module and failure', () {
      expect(_TestError(_TestFailure.save).code, 'test/save');
      expect(
        _TestError(_TestFailure.duplicateName).code,
        'test/duplicateName',
      );
    });

    test('takes its kind and message from the failure', () {
      final error = _TestError(_TestFailure.duplicateName);

      expect(error.kind, ErrorKind.businessRule);
      expect(error.message, 'failed: duplicateName');
    });

    test('falls back to its code while the localizations are missing', () {
      expect(_TestError(_TestFailure.save).message, 'test/save');
    });

    test('constructs before the localizations load', () {
      final error = _TestError(_TestFailure.save);

      expect(error.code, 'test/save');
    });

    test('lets the thrower choose the message', () {
      final error = _TestError(_TestFailure.save, message: 'custom');

      expect(error.message, 'custom');
      expect(error.code, 'test/save');
    });
  });

  group('ErrorKind.of', () {
    test('reads an app error from the error itself', () {
      expect(
        ErrorKind.of(_TestError(_TestFailure.duplicateName)),
        ErrorKind.businessRule,
      );
      expect(ErrorKind.of(_TestError(_TestFailure.save)), ErrorKind.external);
    });

    test('takes any other exception as external', () {
      expect(ErrorKind.of(const FormatException()), ErrorKind.external);
    });

    test('takes an error as a bug', () {
      expect(ErrorKind.of(StateError('x')), ErrorKind.unexpected);
      expect(ErrorKind.of(ArgumentError()), ErrorKind.unexpected);
    });

    test('does not let a wrapper hide a bug', () {
      final error = _TestError(_TestFailure.save, cause: StateError('x'));

      expect(ErrorKind.of(error), ErrorKind.unexpected);
    });
  });

  group('rootCauseOf', () {
    final rootTrace = StackTrace.fromString('root');
    final wrapperTrace = StackTrace.fromString('wrapper');

    test('follows the cause chain to the innermost failure', () {
      const root = FormatException('bad');
      final error = _TestError(
        _TestFailure.save,
        cause: _TestError(_TestFailure.save, cause: root, trace: rootTrace),
        trace: wrapperTrace,
      );

      final result = rootCauseOf(error);

      expect(result.error, same(root));
      expect(result.trace, same(rootTrace));
    });

    test('stops at an app error that has no cause', () {
      final error = _TestError(_TestFailure.duplicateName);

      expect(rootCauseOf(error).error, same(error));
    });

    test('keeps the given trace when nothing deeper has one', () {
      const root = FormatException('bad');

      expect(rootCauseOf(root, wrapperTrace).trace, same(wrapperTrace));
    });
  });
}
