part of 'dashboard_cubit.dart';

class DashboardState extends BaseState with EquatableMixin {
  DashboardState({
    required super.status,
    List<Service>? services,
    super.callbackMessage,
    OrderBy? selectedOrderBy,
  }) : selectedOrderBy = selectedOrderBy ?? OrderBy.dateDesc,
       services = services ?? const [];
  final List<Service> services;
  final OrderBy selectedOrderBy;

  double get totalValue {
    return services.fold<double>(0, (a, b) => a + b.value);
  }

  double get totalWithDiscount {
    return services.fold<double>(0, (a, b) => a + b.valueWithDiscount);
  }

  double get totalDiscounted {
    return services.fold<double>(0, (a, b) => a + b.valueDiscounted);
  }

  @override
  DashboardState copyWith({
    BaseStateStatus? status,
    String? callbackMessage,
    List<Service>? services,
    OrderBy? selectedOrderBy,
  }) {
    return DashboardState(
      status: status ?? this.status,
      callbackMessage: callbackMessage ?? this.callbackMessage,
      services: services ?? this.services,
      selectedOrderBy: selectedOrderBy ?? this.selectedOrderBy,
    );
  }

  @override
  List<Object?> get props => [
    services,
    selectedOrderBy,
    status,
    callbackMessage,
  ];
}
