import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fake_firestore.dart';

void main() {
  late FakeFirestore firestore;
  final now = DateTime.utc(2026, 10, 10, 12);

  setUp(() => firestore = FakeFirestore(clock: () => now));

  CollectionReference<Map<String, dynamic>> items() =>
      firestore.collection('items');

  Future<Map<String, dynamic>?> read(String id) async =>
      (await items().doc(id).get()).data();

  Future<List<String>> ids(Query<Map<String, dynamic>> query) async =>
      (await query.get()).docs.map((doc) => doc.id).toList();

  group('writes', () {
    test('set replaces the whole document', () async {
      await items().doc('a').set({'x': 1, 'y': 2});
      await items().doc('a').set({'x': 3});

      expect(await read('a'), {'x': 3});
    });

    test(
      'set with merge merges nested maps instead of replacing them',
      () async {
        await items().doc('a').set({
          'steps': {'one': 1},
        });
        await items().doc('a').set({
          'steps': {'two': 2},
        }, SetOptions(merge: true));

        expect(await read('a'), {
          'steps': {'one': 1, 'two': 2},
        });
      },
    );

    test(
      'update reads dotted keys as paths and creates what is missing',
      () async {
        await items().doc('a').set({'count': 1});
        await items().doc('a').update({'totals.BRL.generated': 10});

        expect(await read('a'), {
          'count': 1,
          'totals': {
            'BRL': {'generated': 10},
          },
        });
      },
    );

    test('update replaces a map value rather than merging into it', () async {
      await items().doc('a').set({
        'totals': {'BRL': 1, 'USD': 2},
      });
      await items().doc('a').update({
        'totals': {'BRL': 5},
      });

      expect(await read('a'), {
        'totals': {'BRL': 5},
      });
    });

    test('update on a missing document throws not-found', () async {
      await expectLater(
        items().doc('gone').update({'x': 1}),
        throwsA(
          isA<FirebaseException>().having((e) => e.code, 'code', 'not-found'),
        ),
      );
      expect((await items().doc('gone').get()).exists, isFalse);
    });

    test('stores DateTime as Timestamp', () async {
      await items().doc('a').set({'date': DateTime.utc(2026, 1, 2)});

      expect(
        (await read('a'))!['date'],
        Timestamp.fromDate(DateTime.utc(2026, 1, 2)),
      );
    });

    test('never aliases what the caller passed or read', () async {
      final data = {
        'tags': ['a'],
      };
      await items().doc('a').set(data);
      data['tags']!.add('b');
      (await read('a'))!['tags'].add('c');

      expect(await read('a'), {
        'tags': ['a'],
      });
    });
  });

  group('FieldValue', () {
    test('serverTimestamp resolves to the clock', () async {
      await items().doc('a').set({'at': FieldValue.serverTimestamp()});

      expect((await read('a'))!['at'], Timestamp.fromDate(now));
    });

    test('increment adds to the stored value, or starts from zero', () async {
      await items().doc('a').set({'count': 2});
      await items().doc('a').update({
        'count': FieldValue.increment(3),
        'total': FieldValue.increment(1.5),
      });

      expect(await read('a'), {'count': 5, 'total': 1.5});
    });

    test('delete removes the field, in set-merge and in update', () async {
      await items().doc('a').set({'x': 1, 'y': 2, 'z': 3});
      await items().doc('a').set({
        'x': FieldValue.delete(),
      }, SetOptions(merge: true));
      await items().doc('a').update({'y': FieldValue.delete()});

      expect(await read('a'), {'z': 3});
    });
  });

  group('batch', () {
    test('writes nothing until committed', () async {
      final batch = firestore.batch()..set(items().doc('a'), {'x': 1});

      expect((await items().doc('a').get()).exists, isFalse);
      await batch.commit();
      expect(await read('a'), {'x': 1});
    });

    test('is atomic: one failing update undoes the whole batch', () async {
      await items().doc('a').set({'x': 1});
      final batch = firestore.batch()
        ..update(items().doc('a'), {'x': 2})
        ..update(items().doc('gone'), {'x': 2});

      await expectLater(batch.commit(), throwsA(isA<FirebaseException>()));
      expect(await read('a'), {'x': 1});
    });
  });

  group('queries', () {
    Future<void> seed(Map<String, Map<String, dynamic>> docs) async {
      for (final MapEntry(:key, :value) in docs.entries) {
        await items().doc(key).set(value);
      }
    }

    test('scopes to the collection, not to its subcollections', () async {
      await seed({'a': {}});
      await items().doc('a').collection('items').doc('b').set({});

      expect(await ids(items()), ['a']);
    });

    test('range filters compare DateTime with stored Timestamps', () async {
      await seed({
        'jan': {'date': DateTime.utc(2026)},
        'mar': {'date': DateTime.utc(2026, 3)},
      });

      expect(
        await ids(
          items().where('date', isGreaterThanOrEqualTo: DateTime.utc(2026, 2)),
        ),
        ['mar'],
      );
    });

    test('range filters never match a value of another type', () async {
      await seed({
        'number': {'v': 5},
        'text': {'v': 'z'},
      });

      expect(await ids(items().where('v', isGreaterThan: 1)), ['number']);
    });

    test('filters and ordering skip documents missing the field', () async {
      await seed({
        'with': {'v': 1},
        'without': {},
      });

      expect(await ids(items().where('v', isNotEqualTo: 2)), ['with']);
      expect(await ids(items().orderBy('v')), ['with']);
    });

    test('documentId filters and orders by the id', () async {
      await seed({'b': {}, 'a': {}, 'c': {}});

      expect(
        await ids(
          items()
              .where(FieldPath.documentId, isGreaterThan: 'a')
              .orderBy(FieldPath.documentId),
        ),
        ['b', 'c'],
      );
      expect(
        await ids(items().where(FieldPath.documentId, whereIn: ['c', 'a'])),
        ['a', 'c'],
      );
    });

    test('cursors follow a descending order', () async {
      await seed({
        'jan': {'date': DateTime.utc(2026)},
        'feb': {'date': DateTime.utc(2026, 2)},
        'mar': {'date': DateTime.utc(2026, 3)},
      });
      final newestFirst = items().orderBy('date', descending: true);

      expect(await ids(newestFirst.startAfter([DateTime.utc(2026, 3)])), [
        'feb',
        'jan',
      ]);
      expect(
        await ids(
          newestFirst.startAt([Timestamp.fromDate(DateTime.utc(2026, 2))]),
        ),
        ['feb', 'jan'],
      );
    });

    test('startAt and endAt bound a prefix search', () async {
      await seed({
        'ana': {'name': 'Ana'},
        'anabela': {'name': 'Anabela'},
        'bruno': {'name': 'Bruno'},
      });

      expect(
        await ids(
          items().orderBy('name').startAt(['Ana']).endAt(['Ana\u{F8FF}']),
        ),
        ['ana', 'anabela'],
      );
    });

    test('limitToLast keeps the last ones, in query order', () async {
      await seed({'a': {}, 'b': {}, 'c': {}});

      expect(
        await ids(
          items().orderBy(FieldPath.documentId).endAt(['b']).limitToLast(1),
        ),
        ['b'],
      );
      expect(await ids(items().orderBy(FieldPath.documentId).limitToLast(2)), [
        'b',
        'c',
      ]);
    });

    test('count counts what the query matches', () async {
      await seed({
        'a': {'owner': 'me'},
        'b': {'owner': 'me'},
        'c': {'owner': 'you'},
      });

      final snapshot = await items()
          .where('owner', isEqualTo: 'me')
          .count()
          .get();

      expect(snapshot.count, 2);
    });
  });
}
