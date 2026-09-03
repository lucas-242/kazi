import 'package:equatable/equatable.dart';
import 'package:kazi_core/kazi_core.dart';

class ClientInfo extends Equatable {
  const ClientInfo({
    required this.user,
    required this.lastServiceName,
    required this.lastServiceDate,
    required this.mostUsedServices,
    this.serviceHistory = const [],
  });

  ClientInfo.empty()
      : user = User(
          id: 0,
          name: '',
          email: '',
          document: '',
          birthDate: DateTime(2000),
          userType: UserType.client,
          authToken: '',
          refreshToken: '',
          authExpires: DateTime(2100),
        ),
        lastServiceName = '',
        lastServiceDate = DateTime(2000),
        mostUsedServices = const {},
        serviceHistory = const [];

  final User user;
  final String lastServiceName;
  final DateTime lastServiceDate;
  final Map<String, int> mostUsedServices;
  final List<ServiceHistoryItem> serviceHistory;

  bool get isLastServiceLate =>
      DateTime.now().difference(lastServiceDate).inDays >= 20;

  int get daysSinceLastService =>
      DateTime.now().difference(lastServiceDate).inDays;

  String get lastServiceDateFormatted =>
      '${lastServiceDate.day.toString().padLeft(2, '0')}/${lastServiceDate.month.toString().padLeft(2, '0')}/${lastServiceDate.year}';

  @override
  List<Object?> get props => [
        user,
        lastServiceName,
        lastServiceDate,
        mostUsedServices,
        serviceHistory,
      ];
}

class ServiceHistoryItem extends Equatable {
  const ServiceHistoryItem({
    required this.serviceName,
    required this.professionalName,
    required this.date,
    this.notes,
  });
  final String serviceName;
  final String professionalName;
  final DateTime date;
  final String? notes;

  String get formattedDate =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  @override
  List<Object?> get props => [serviceName, professionalName, date, notes];
}
