import 'package:equatable/equatable.dart';

/// An inclusive span of days.
///
/// Both ends carry a time component: [start] is the first instant of its day
/// and [end] the last, so a range can be handed straight to a Firestore
/// `date >= start && date <= end` query without further massaging.
class DateRange extends Equatable {
  const DateRange({required this.start, required this.end});

  final DateTime start;
  final DateTime end;

  /// Whether [date] falls inside the range, both ends included.
  bool contains(DateTime date) => !date.isBefore(start) && !date.isAfter(end);

  @override
  List<Object?> get props => [start, end];
}
