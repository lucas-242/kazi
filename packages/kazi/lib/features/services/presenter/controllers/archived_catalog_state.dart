import 'package:equatable/equatable.dart';
import 'package:kazi/core/utils/base_state.dart';

class ArchivedCatalogState extends BaseState with Equatable {
  ArchivedCatalogState({
    Map<String, int>? serviceCounts,
    required super.status,
    super.callbackMessage,
  }) : serviceCounts = serviceCounts ?? const {};

  /// Services pointing at each archived item, keyed by item id. A missing key
  /// means the count has not loaded yet, which reads as "not deletable" — the
  /// safe answer while we do not know.
  final Map<String, int> serviceCounts;

  int? countFor(String id) => serviceCounts[id];

  bool canDelete(String id) => serviceCounts[id] == 0;

  @override
  ArchivedCatalogState copyWith({
    Map<String, int>? serviceCounts,
    BaseStateStatus? status,
    String? callbackMessage,
  }) {
    return ArchivedCatalogState(
      serviceCounts: serviceCounts ?? this.serviceCounts,
      status: status ?? this.status,
      callbackMessage: callbackMessage ?? this.callbackMessage,
    );
  }

  @override
  List<Object?> get props => [serviceCounts, status, callbackMessage];
}
