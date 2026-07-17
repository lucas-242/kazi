import 'package:equatable/equatable.dart';
import 'package:kazi_core/kazi_core.dart';

class ServiceFiltersState with EquatableMixin {
  ServiceFiltersState({
    required this.startDate,
    required this.endDate,
    required this.fastSearch,
    this.didFiltersChange = false,
  });
  final DateTime startDate;
  final DateTime endDate;
  final FastSearch fastSearch;
  final bool didFiltersChange;

  @override
  List<Object?> get props => [startDate, endDate, fastSearch, didFiltersChange];
}
