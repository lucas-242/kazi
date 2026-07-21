import 'package:equatable/equatable.dart';
import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/services/domain/models/service_type.dart';

class ServiceTypesState extends BaseState with Equatable {
  ServiceTypesState({
    required this.userId,
    ServiceType? serviceType,
    List<ServiceType>? serviceTypeList,
    required super.status,
    super.callbackMessage,
  }) : serviceType = serviceType ?? ServiceType(userId: userId),
       serviceTypes = serviceTypeList ?? [];
  final List<ServiceType> serviceTypes;
  final ServiceType serviceType;
  final String userId;

  @override
  ServiceTypesState copyWith({
    List<ServiceType>? serviceTypes,
    ServiceType? serviceType,
    BaseStateStatus? status,
    String? callbackMessage,
  }) {
    return ServiceTypesState(
      status: status ?? this.status,
      serviceType: serviceType ?? this.serviceType,
      serviceTypeList: serviceTypes ?? this.serviceTypes,
      callbackMessage: callbackMessage ?? this.callbackMessage,
      userId: userId,
    );
  }

  @override
  List<Object?> get props => [
    serviceTypes,
    serviceType,
    userId,
    status,
    callbackMessage,
  ];
}
