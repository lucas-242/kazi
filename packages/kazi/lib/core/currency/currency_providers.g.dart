// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Rate snapshots for a single day, for screens that show one amount rather
/// than an aggregate. Keyed by the `yyyy-MM-dd` string, so repeated reads of
/// the same day share one provider instance.

@ProviderFor(dayRateBook)
const dayRateBookProvider = DayRateBookFamily._();

/// Rate snapshots for a single day, for screens that show one amount rather
/// than an aggregate. Keyed by the `yyyy-MM-dd` string, so repeated reads of
/// the same day share one provider instance.

final class DayRateBookProvider
    extends
        $FunctionalProvider<AsyncValue<RateBook>, RateBook, FutureOr<RateBook>>
    with $FutureModifier<RateBook>, $FutureProvider<RateBook> {
  /// Rate snapshots for a single day, for screens that show one amount rather
  /// than an aggregate. Keyed by the `yyyy-MM-dd` string, so repeated reads of
  /// the same day share one provider instance.
  const DayRateBookProvider._({
    required DayRateBookFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'dayRateBookProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dayRateBookHash();

  @override
  String toString() {
    return r'dayRateBookProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<RateBook> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<RateBook> create(Ref ref) {
    final argument = this.argument as String;
    return dayRateBook(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DayRateBookProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dayRateBookHash() => r'5f111015c91892e51bdc1fc116261e5b72ba67ac';

/// Rate snapshots for a single day, for screens that show one amount rather
/// than an aggregate. Keyed by the `yyyy-MM-dd` string, so repeated reads of
/// the same day share one provider instance.

final class DayRateBookFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<RateBook>, String> {
  const DayRateBookFamily._()
    : super(
        retry: null,
        name: r'dayRateBookProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Rate snapshots for a single day, for screens that show one amount rather
  /// than an aggregate. Keyed by the `yyyy-MM-dd` string, so repeated reads of
  /// the same day share one provider instance.

  DayRateBookProvider call(String dateKey) =>
      DayRateBookProvider._(argument: dateKey, from: this);

  @override
  String toString() => r'dayRateBookProvider';
}
