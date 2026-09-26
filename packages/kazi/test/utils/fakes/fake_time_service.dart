import 'package:kazi/core/services/data/local_time_service.dart';
import 'package:kazi/core/services/domain/time_service.dart';

/// [TimeService] pinned to a fixed date.
///
/// Delegates to [LocalTimeService] rather than reimplementing the month
/// arithmetic, so a change to the real rules is reflected here for free.
class FakeTimeService implements TimeService {
  FakeTimeService([DateTime? now])
    : _delegate = LocalTimeService(now ?? DateTime(2026, 7, 15));

  final LocalTimeService _delegate;

  @override
  DateTime get now => _delegate.now;

  @override
  bool isRangeInLastMonth(DateTime start, DateTime end) =>
      _delegate.isRangeInLastMonth(start, end);

  @override
  bool isRangeInThisMonth(DateTime start, DateTime end) =>
      _delegate.isRangeInThisMonth(start, end);
}
