import 'package:flutter_test/flutter_test.dart';
import 'package:kazi_core/kazi_core.dart';

void main() {
  group('describeError', () {
    test('prints an app error by code, kind and message', () {
      final error = ApiError(ApiFailure.notFound, message: 'Name is required');

      expect(Log.describeError(error), [
        'Error: api/notFound (business_rule) — Name is required',
      ]);
    });

    test('prints each cause beneath it', () {
      final error = StorageError(
        StorageFailure.write,
        message: 'Could not save',
        cause: StorageError(
          StorageFailure.read,
          message: 'Could not read',
          cause: const FormatException('bad'),
        ),
      );

      expect(Log.describeError(error), [
        'Error: storage/write (external) — Could not save',
        'Cause: storage/read — Could not read',
        'Cause: FormatException: bad',
      ]);
    });

    test('prints anything else as it describes itself', () {
      expect(Log.describeError(StateError('bug')), ['Error: Bad state: bug']);
    });
  });
}
