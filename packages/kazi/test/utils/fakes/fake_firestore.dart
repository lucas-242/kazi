import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore_platform_interface/cloud_firestore_platform_interface.dart'
    show FieldPathType, FieldValueFactoryPlatform, FieldValuePlatform;
import 'package:flutter_test/flutter_test.dart';

/// In-memory [FirebaseFirestore] covering the subset of the SDK the app uses.
/// Anything outside it throws [UnimplementedError]; see README.md.
class FakeFirestore extends Fake implements FirebaseFirestore {
  /// [clock] is what `FieldValue.serverTimestamp()` resolves to.
  FakeFirestore({DateTime Function()? clock}) : _clock = clock ?? DateTime.now {
    // A FieldValue built before this runs carries the SDK's own delegate,
    // which the fake cannot read.
    FieldValueFactoryPlatform.instance = _SentinelFactory();
  }

  final DateTime Function() _clock;
  final Map<String, Map<String, dynamic>> _documents = {};
  final Random _random = Random();

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) =>
      _CollectionReference(this, collectionPath);

  @override
  DocumentReference<Map<String, dynamic>> doc(String documentPath) =>
      _DocumentReference(this, documentPath);

  @override
  WriteBatch batch() => _WriteBatch(this);

  String _autoId() {
    const alphabet =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return String.fromCharCodes(
      List.generate(
        20,
        (_) => alphabet.codeUnitAt(_random.nextInt(alphabet.length)),
      ),
    );
  }

  Map<String, dynamic>? _read(String path) {
    final data = _documents[path];
    return data == null ? null : _copy(data) as Map<String, dynamic>;
  }

  Iterable<MapEntry<String, Map<String, dynamic>>> _documentsIn(
    String collectionPath,
  ) => _documents.entries.where(
    (entry) => _parentOf(entry.key) == collectionPath,
  );

  void _set(String path, Map<String, dynamic> data, SetOptions? options) {
    if (options?.mergeFields != null) {
      throw UnimplementedError('FakeFirestore does not support mergeFields');
    }
    final existing = _documents[path];
    final merge = options?.merge ?? false;
    final target = merge && existing != null
        ? _copy(existing) as Map<String, dynamic>
        : <String, dynamic>{};
    _documents[path] = _writeFields(target, data);
  }

  void _update(String path, Map<Object, Object?> data) {
    final existing = _documents[path];
    if (existing == null) {
      throw FirebaseException(
        plugin: 'cloud_firestore',
        code: 'not-found',
        message: 'No document to update: $path',
      );
    }

    final next = _copy(existing) as Map<String, dynamic>;
    data.forEach((field, value) => _writePath(next, _segmentsOf(field), value));
    _documents[path] = next;
  }

  void _delete(String path) => _documents.remove(path);

  /// Stored maps are never mutated in place, so a shallow copy is a backup.
  void _atomically(void Function() writes) {
    final backup = Map.of(_documents);
    try {
      writes();
    } catch (_) {
      _documents
        ..clear()
        ..addAll(backup);
      rethrow;
    }
  }

  /// Merges [data] into [target]: nested maps merge, everything else replaces.
  Map<String, dynamic> _writeFields(
    Map<String, dynamic> target,
    Map<Object?, Object?> data,
  ) {
    data.forEach((key, value) {
      final field = key! as String;
      final current = target[field];
      if (_sentinelOf(value) is _Delete) {
        target.remove(field);
      } else if (value is Map) {
        target[field] = _writeFields(
          current is Map<String, dynamic> ? current : <String, dynamic>{},
          value,
        );
      } else {
        target[field] = _resolve(value, current);
      }
    });
    return target;
  }

  /// `update` semantics: [segments] is a path, and a map value replaces
  /// whatever was there rather than merging into it.
  void _writePath(
    Map<String, dynamic> target,
    List<String> segments,
    Object? value,
  ) {
    var node = target;
    for (final segment in segments.take(segments.length - 1)) {
      final child = node[segment];
      node = node[segment] = child is Map<String, dynamic>
          ? child
          : <String, dynamic>{};
    }

    final leaf = segments.last;
    if (_sentinelOf(value) is _Delete) {
      node.remove(leaf);
    } else if (value is Map) {
      node[leaf] = _writeFields(<String, dynamic>{}, value);
    } else {
      node[leaf] = _resolve(value, node[leaf]);
    }
  }

  Object? _resolve(Object? value, Object? current) {
    if (value is! FieldValue) return _normalize(value);

    return switch (_sentinelOf(value)) {
      _ServerTimestamp() => Timestamp.fromDate(_clock()),
      _Increment(:final by) => current is num ? current + by : by,
      _ArrayUnion(:final elements) => [
        ...?current is List ? current : null,
        for (final element in elements.map(_normalize))
          if (!(current is List && current.any((e) => _equals(e, element))))
            element,
      ],
      _ArrayRemove(:final elements) => [
        if (current is List)
          for (final e in current)
            if (!elements.map(_normalize).any((r) => _equals(e, r))) e,
      ],
      _Delete() => throw StateError(
        'FieldValue.delete() is resolved by the caller',
      ),
      null => throw StateError(
        'A FieldValue was built before FakeFirestore was constructed',
      ),
    };
  }
}

// ignore: subtype_of_sealed_class
class _CollectionReference extends _Query
    implements CollectionReference<Map<String, dynamic>> {
  _CollectionReference(super._firestore, super._collectionPath);

  @override
  String get id => _lastSegmentOf(path);

  @override
  String get path => _collectionPath;

  @override
  DocumentReference<Map<String, dynamic>>? get parent {
    final parentPath = _parentOf(path);
    return parentPath.isEmpty
        ? null
        : _DocumentReference(_firestore, parentPath);
  }

  @override
  DocumentReference<Map<String, dynamic>> doc([String? documentPath]) =>
      _DocumentReference(
        _firestore,
        '$path/${documentPath ?? _firestore._autoId()}',
      );

  @override
  Future<DocumentReference<Map<String, dynamic>>> add(
    Map<String, dynamic> data,
  ) async {
    final reference = doc();
    await reference.set(data);
    return reference;
  }
}

// ignore: subtype_of_sealed_class
class _DocumentReference extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  _DocumentReference(this._firestore, this.path);

  final FakeFirestore _firestore;

  @override
  final String path;

  @override
  FirebaseFirestore get firestore => _firestore;

  @override
  String get id => _lastSegmentOf(path);

  @override
  CollectionReference<Map<String, dynamic>> get parent =>
      _CollectionReference(_firestore, _parentOf(path));

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) =>
      _CollectionReference(_firestore, '$path/$collectionPath');

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> get([
    GetOptions? options,
  ]) async => _DocumentSnapshot(this, _firestore._read(path));

  @override
  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) async =>
      _firestore._set(path, data, options);

  @override
  Future<void> update(Map<Object, Object?> data) async =>
      _firestore._update(path, data);

  @override
  Future<void> delete() async => _firestore._delete(path);

  @override
  bool operator ==(Object other) =>
      other is _DocumentReference &&
      identical(other._firestore, _firestore) &&
      other.path == path;

  @override
  int get hashCode => Object.hash(_firestore, path);

  @override
  String toString() => 'DocumentReference($path)';
}

// ignore: subtype_of_sealed_class
class _DocumentSnapshot extends Fake
    implements DocumentSnapshot<Map<String, dynamic>> {
  _DocumentSnapshot(this.reference, this._data);

  final Map<String, dynamic>? _data;

  @override
  final DocumentReference<Map<String, dynamic>> reference;

  @override
  String get id => reference.id;

  @override
  bool get exists => _data != null;

  @override
  Map<String, dynamic>? data() => _data;

  @override
  dynamic get(Object field) {
    final value = _valueAt(_data ?? const {}, _segmentsOf(field));
    if (identical(value, _missing)) {
      throw StateError('Field $field does not exist in ${reference.path}');
    }
    return value;
  }

  @override
  dynamic operator [](Object field) => get(field);
}

// ignore: subtype_of_sealed_class
class _QueryDocumentSnapshot extends _DocumentSnapshot
    implements QueryDocumentSnapshot<Map<String, dynamic>> {
  _QueryDocumentSnapshot(super.reference, Map<String, dynamic> super._data);

  @override
  Map<String, dynamic> data() => super.data()!;
}

class _QuerySnapshot extends Fake
    implements QuerySnapshot<Map<String, dynamic>> {
  _QuerySnapshot(this.docs);

  @override
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> docs;

  @override
  int get size => docs.length;
}

class _AggregateQuery extends Fake implements AggregateQuery {
  _AggregateQuery(this._count);

  final Future<int> Function() _count;

  @override
  Future<AggregateQuerySnapshot> get({
    AggregateSource source = AggregateSource.server,
  }) async => _CountSnapshot(await _count());
}

class _CountSnapshot extends Fake implements AggregateQuerySnapshot {
  _CountSnapshot(this.count);

  @override
  final int? count;
}

class _WriteBatch extends Fake implements WriteBatch {
  _WriteBatch(this._firestore);

  final FakeFirestore _firestore;
  final List<void Function()> _writes = [];

  @override
  void set<T>(DocumentReference<T> document, T data, [SetOptions? options]) =>
      _writes.add(
        () => _firestore._set(
          document.path,
          data as Map<String, dynamic>,
          options,
        ),
      );

  @override
  void update<T>(DocumentReference<T> document, T data) => _writes.add(
    () => _firestore._update(document.path, data as Map<Object, Object?>),
  );

  @override
  void delete(DocumentReference document) =>
      _writes.add(() => _firestore._delete(document.path));

  @override
  Future<void> commit() async => _firestore._atomically(() {
    for (final write in _writes) {
      write();
    }
  });
}

enum _Operator {
  isEqualTo,
  isNotEqualTo,
  isLessThan,
  isLessThanOrEqualTo,
  isGreaterThan,
  isGreaterThanOrEqualTo,
  arrayContains,
  arrayContainsAny,
  whereIn,
  whereNotIn,
  isNull,
}

typedef _Filter = ({Object field, _Operator operator, Object? operand});
typedef _Ordering = ({Object field, bool descending});
typedef _Cursor = ({List<Object?> values, bool inclusive});

// ignore: subtype_of_sealed_class
class _Query extends Fake implements Query<Map<String, dynamic>> {
  _Query(
    this._firestore,
    this._collectionPath, {
    List<_Filter> filters = const [],
    List<_Ordering> orderings = const [],
    _Cursor? start,
    _Cursor? end,
    int? limit,
    bool limitToLast = false,
  }) : _filters = filters,
       _orderings = orderings,
       _start = start,
       _end = end,
       _limit = limit,
       _limitToLast = limitToLast;

  final FakeFirestore _firestore;
  final String _collectionPath;
  final List<_Filter> _filters;
  final List<_Ordering> _orderings;
  final _Cursor? _start;
  final _Cursor? _end;
  final int? _limit;
  final bool _limitToLast;

  @override
  FirebaseFirestore get firestore => _firestore;

  _Query _copyWith({
    List<_Filter>? filters,
    List<_Ordering>? orderings,
    _Cursor? start,
    _Cursor? end,
    int? limit,
    bool? limitToLast,
  }) => _Query(
    _firestore,
    _collectionPath,
    filters: filters ?? _filters,
    orderings: orderings ?? _orderings,
    start: start ?? _start,
    end: end ?? _end,
    limit: limit ?? _limit,
    limitToLast: limitToLast ?? _limitToLast,
  );

  @override
  Query<Map<String, dynamic>> where(
    Object field, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    Iterable<Object?>? arrayContainsAny,
    Iterable<Object?>? whereIn,
    Iterable<Object?>? whereNotIn,
    bool? isNull,
  }) {
    if (field is Filter) {
      throw UnimplementedError('FakeFirestore does not support Filter');
    }

    // Like the SDK, a null operand means "not passed"; only isNull matches null.
    final operands = {
      _Operator.isEqualTo: isEqualTo,
      _Operator.isNotEqualTo: isNotEqualTo,
      _Operator.isLessThan: isLessThan,
      _Operator.isLessThanOrEqualTo: isLessThanOrEqualTo,
      _Operator.isGreaterThan: isGreaterThan,
      _Operator.isGreaterThanOrEqualTo: isGreaterThanOrEqualTo,
      _Operator.arrayContains: arrayContains,
      _Operator.arrayContainsAny: arrayContainsAny?.map(_normalize).toList(),
      _Operator.whereIn: whereIn?.map(_normalize).toList(),
      _Operator.whereNotIn: whereNotIn?.map(_normalize).toList(),
      _Operator.isNull: isNull,
    };

    return _copyWith(
      filters: [
        ..._filters,
        for (final MapEntry(key: operator, value: operand) in operands.entries)
          if (operand != null)
            (field: field, operator: operator, operand: _normalize(operand)),
      ],
    );
  }

  @override
  Query<Map<String, dynamic>> orderBy(
    Object field, {
    bool descending = false,
  }) => _copyWith(
    orderings: [..._orderings, (field: field, descending: descending)],
  );

  @override
  Query<Map<String, dynamic>> limit(int limit) =>
      _copyWith(limit: limit, limitToLast: false);

  @override
  Query<Map<String, dynamic>> limitToLast(int limit) =>
      _copyWith(limit: limit, limitToLast: true);

  @override
  Query<Map<String, dynamic>> startAt(Iterable<Object?> values) =>
      _copyWith(start: (values: values.toList(), inclusive: true));

  @override
  Query<Map<String, dynamic>> startAfter(Iterable<Object?> values) =>
      _copyWith(start: (values: values.toList(), inclusive: false));

  @override
  Query<Map<String, dynamic>> endAt(Iterable<Object?> values) =>
      _copyWith(end: (values: values.toList(), inclusive: true));

  @override
  Query<Map<String, dynamic>> endBefore(Iterable<Object?> values) =>
      _copyWith(end: (values: values.toList(), inclusive: false));

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> get([
    GetOptions? options,
  ]) async => _QuerySnapshot(_run());

  @override
  AggregateQuery count() => _AggregateQuery(() async => _run().length);

  List<QueryDocumentSnapshot<Map<String, dynamic>>> _run() {
    // Firestore breaks ties by document id, in the direction of the last
    // explicit ordering.
    final orderings = [
      ..._orderings,
      if (!_orderings.any((o) => o.field is FieldPathType))
        (
          field: FieldPath.documentId as Object,
          descending: _orderings.lastOrNull?.descending ?? false,
        ),
    ];

    final matching = [
      for (final entry in _firestore._documentsIn(_collectionPath))
        if (_filters.every((filter) => _matches(filter, entry)) &&
            orderings.every(
              (o) => !identical(_fieldOf(entry, o.field), _missing),
            ))
          entry,
    ];

    List<Object?> sortKey(MapEntry<String, Map<String, dynamic>> entry) => [
      for (final ordering in orderings) _fieldOf(entry, ordering.field),
    ];

    int compareToCursor(
      MapEntry<String, Map<String, dynamic>> entry,
      List<Object?> cursor,
    ) {
      final key = sortKey(entry);
      for (var i = 0; i < cursor.length && i < orderings.length; i++) {
        final order = _compare(key[i], _normalize(cursor[i]));
        if (order != 0) return orderings[i].descending ? -order : order;
      }
      return 0;
    }

    matching.sort((a, b) {
      final keyA = sortKey(a);
      final keyB = sortKey(b);
      for (var i = 0; i < orderings.length; i++) {
        final order = _compare(keyA[i], keyB[i]);
        if (order != 0) return orderings[i].descending ? -order : order;
      }
      return 0;
    });

    final start = _start;
    final end = _end;
    var result = matching.where((entry) {
      if (start != null) {
        final order = compareToCursor(entry, start.values);
        if (start.inclusive ? order < 0 : order <= 0) return false;
      }
      if (end != null) {
        final order = compareToCursor(entry, end.values);
        if (end.inclusive ? order > 0 : order >= 0) return false;
      }
      return true;
    }).toList();

    final limit = _limit;
    if (limit != null && result.length > limit) {
      result = _limitToLast
          ? result.sublist(result.length - limit)
          : result.sublist(0, limit);
    }

    return [
      for (final entry in result)
        _QueryDocumentSnapshot(
          _DocumentReference(_firestore, entry.key),
          _copy(entry.value) as Map<String, dynamic>,
        ),
    ];
  }

  bool _matches(_Filter filter, MapEntry<String, Map<String, dynamic>> entry) {
    final value = _fieldOf(entry, filter.field);
    if (identical(value, _missing)) return false;

    final operand = filter.operand;
    bool sameKind() => value != null && _kindOf(value) == _kindOf(operand);

    return switch (filter.operator) {
      _Operator.isEqualTo => _equals(value, operand),
      _Operator.isNotEqualTo => value != null && !_equals(value, operand),
      _Operator.isLessThan => sameKind() && _compare(value, operand) < 0,
      _Operator.isLessThanOrEqualTo =>
        sameKind() && _compare(value, operand) <= 0,
      _Operator.isGreaterThan => sameKind() && _compare(value, operand) > 0,
      _Operator.isGreaterThanOrEqualTo =>
        sameKind() && _compare(value, operand) >= 0,
      _Operator.arrayContains =>
        value is List && value.any((e) => _equals(e, operand)),
      _Operator.arrayContainsAny =>
        value is List &&
            value.any((e) => (operand! as List).any((o) => _equals(e, o))),
      _Operator.whereIn => (operand! as List).any((o) => _equals(value, o)),
      _Operator.whereNotIn =>
        value != null && !(operand! as List).any((o) => _equals(value, o)),
      _Operator.isNull => (value == null) == operand,
    };
  }
}

/// The document id stands in for `FieldPath.documentId`, compared as a string.
Object? _fieldOf(MapEntry<String, Map<String, dynamic>> entry, Object field) =>
    field is FieldPathType
    ? _lastSegmentOf(entry.key)
    : _valueAt(entry.value, _segmentsOf(field));

final Object _missing = Object();

Object? _valueAt(Map<String, dynamic> data, List<String> segments) {
  Object? node = data;
  for (final segment in segments) {
    if (node is! Map || !node.containsKey(segment)) return _missing;
    node = node[segment];
  }
  return node;
}

List<String> _segmentsOf(Object field) => switch (field) {
  final FieldPath path => path.components,
  final String path => path.split('.'),
  _ => throw UnimplementedError('FakeFirestore does not support $field'),
};

String _parentOf(String path) {
  final slash = path.lastIndexOf('/');
  return slash < 0 ? '' : path.substring(0, slash);
}

String _lastSegmentOf(String path) => path.substring(path.lastIndexOf('/') + 1);

/// What the SDK's codec does on the way in: `DateTime` is stored as
/// [Timestamp], and the store never aliases a caller's collections.
Object? _normalize(Object? value) => switch (value) {
  final DateTime date => Timestamp.fromDate(date),
  final Map<Object?, Object?> map => <String, dynamic>{
    for (final MapEntry(:key, :value) in map.entries)
      key! as String: _normalize(value),
  },
  final List<Object?> list => [for (final e in list) _normalize(e)],
  _ => value,
};

Object? _copy(Object? value) => switch (value) {
  final Map<Object?, Object?> map => <String, dynamic>{
    for (final MapEntry(:key, :value) in map.entries)
      key! as String: _copy(value),
  },
  final List<Object?> list => [for (final e in list) _copy(e)],
  _ => value,
};

/// Firestore's cross-type ordering; values of different kinds never match a
/// range filter, but still sort against each other.
int _kindOf(Object? value) => switch (value) {
  null => 0,
  bool() => 1,
  num() => 2,
  Timestamp() => 3,
  String() => 4,
  Blob() => 5,
  DocumentReference() => 6,
  GeoPoint() => 7,
  List() => 8,
  Map() => 9,
  _ => throw UnimplementedError('FakeFirestore cannot compare $value'),
};

bool _equals(Object? a, Object? b) =>
    _kindOf(a) == _kindOf(b) && _compare(a, b) == 0;

int _compare(Object? a, Object? b) {
  final kind = _kindOf(a).compareTo(_kindOf(b));
  if (kind != 0) return kind;

  return switch ((a, b)) {
    (final bool x, final bool y) => (x ? 1 : 0).compareTo(y ? 1 : 0),
    (final num x, final num y) => x.compareTo(y),
    (final Timestamp x, final Timestamp y) => x.compareTo(y),
    (final String x, final String y) => x.compareTo(y),
    (final Blob x, final Blob y) => _compareLists(x.bytes, y.bytes),
    (final DocumentReference x, final DocumentReference y) => x.path.compareTo(
      y.path,
    ),
    (final GeoPoint x, final GeoPoint y) =>
      x.latitude != y.latitude
          ? x.latitude.compareTo(y.latitude)
          : x.longitude.compareTo(y.longitude),
    (final List<Object?> x, final List<Object?> y) => _compareLists(x, y),
    (final Map<Object?, Object?> x, final Map<Object?, Object?> y) =>
      _compareMaps(x, y),
    _ => 0,
  };
}

int _compareLists(List<Object?> a, List<Object?> b) {
  for (var i = 0; i < a.length && i < b.length; i++) {
    final order = _compare(a[i], b[i]);
    if (order != 0) return order;
  }
  return a.length.compareTo(b.length);
}

int _compareMaps(Map<Object?, Object?> a, Map<Object?, Object?> b) {
  final keysA = a.keys.cast<String>().toList()..sort();
  final keysB = b.keys.cast<String>().toList()..sort();
  for (var i = 0; i < keysA.length && i < keysB.length; i++) {
    final key = keysA[i].compareTo(keysB[i]);
    if (key != 0) return key;
    final value = _compare(a[keysA[i]], b[keysB[i]]);
    if (value != 0) return value;
  }
  return keysA.length.compareTo(keysB.length);
}

_Sentinel? _sentinelOf(Object? value) {
  if (value is! FieldValue) return null;
  final delegate = FieldValuePlatform.getDelegate(value);
  return delegate is _Sentinel ? delegate : null;
}

sealed class _Sentinel {
  const _Sentinel();
}

class _Delete extends _Sentinel {
  const _Delete();
}

class _ServerTimestamp extends _Sentinel {
  const _ServerTimestamp();
}

class _Increment extends _Sentinel {
  const _Increment(this.by);

  final num by;
}

class _ArrayUnion extends _Sentinel {
  const _ArrayUnion(this.elements);

  final List<dynamic> elements;
}

class _ArrayRemove extends _Sentinel {
  const _ArrayRemove(this.elements);

  final List<dynamic> elements;
}

class _SentinelFactory extends FieldValueFactoryPlatform {
  @override
  dynamic arrayUnion(List<dynamic> elements) => _ArrayUnion(elements);

  @override
  dynamic arrayRemove(List<dynamic> elements) => _ArrayRemove(elements);

  @override
  dynamic delete() => const _Delete();

  @override
  dynamic serverTimestamp() => const _ServerTimestamp();

  @override
  dynamic increment(num value) => _Increment(value);
}
