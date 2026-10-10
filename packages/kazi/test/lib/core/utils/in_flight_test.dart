import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/utils/in_flight.dart';

void main() {
  late InFlight inFlight;

  setUp(() => inFlight = InFlight());

  test('drops a second call with the same key while the first runs', () async {
    final release = Completer<void>();
    var runs = 0;

    final first = inFlight.run('save', () async {
      runs++;
      await release.future;
      return 'saved';
    });
    final second = inFlight.run('save', () async {
      runs++;
      return 'saved again';
    });
    release.complete();

    expect(await first, 'saved');
    expect(await second, isNull, reason: 'dropped, never run');
    expect(runs, 1);
  });

  test('runs different keys side by side', () async {
    final release = Completer<void>();
    final runs = <String>[];

    final first = inFlight.run(('archive', 'a'), () async {
      runs.add('a');
      await release.future;
    });
    final second = inFlight.run(('archive', 'b'), () async => runs.add('b'));
    release.complete();
    await Future.wait([first, second]);

    expect(runs, ['a', 'b']);
  });

  test('takes the key again once the call has finished', () async {
    await inFlight.run('save', () async {});

    expect(await inFlight.run('save', () async => 'again'), 'again');
  });

  test('releases the key when the call fails', () async {
    await expectLater(
      inFlight.run('save', () async => throw StateError('offline')),
      throwsStateError,
    );

    expect(await inFlight.run('save', () async => 'retried'), 'retried');
  });
}
