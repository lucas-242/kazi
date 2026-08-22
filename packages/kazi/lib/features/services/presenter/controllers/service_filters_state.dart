import 'package:equatable/equatable.dart';
import 'package:kazi_core/kazi_core.dart';

class ServiceFiltersState with Equatable {
  ServiceFiltersState({
    required this.startDate,
    required this.endDate,
    required this.fastSearch,
    this.isCurrentCycle = false,
  });
  final DateTime startDate;
  final DateTime endDate;
  final FastSearch fastSearch;

  /// Whether the window came from the user's pay cycle rather than a
  /// [FastSearch] preset.
  ///
  /// The cycle is deliberately not a `FastSearch` value: that enum is a fixed
  /// set of calendar presets, while the cycle is configured per user. It rides
  /// along as `FastSearch.custom` plus this flag, which is what lets its chip
  /// render as selected.
  final bool isCurrentCycle;

  @override
  List<Object?> get props => [
    startDate,
    endDate,
    fastSearch,
    isCurrentCycle,
  ];
}
