import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// How a failure should be read when it reaches Crashlytics or analytics.
///
/// Follows Dart's own split: an [Exception] is a condition the app has to
/// expect, an [Error] is a bug.
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

  static ErrorKind of(Object error) => switch (error) {
    ClientError() => businessRule,
    Error() => unexpected,
    _ => external,
  };
}
