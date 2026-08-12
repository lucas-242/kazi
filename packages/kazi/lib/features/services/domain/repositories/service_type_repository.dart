import 'package:kazi/features/services/domain/models/service_type.dart';

abstract class ServiceTypeRepository {
  Future<ServiceType> add(ServiceType serviceType);

  /// Writes [serviceTypes] in one atomic batch, returning them with their
  /// generated ids. Used to seed a whole profession preset: one round trip, and
  /// a network failure leaves no half-written catalog behind.
  Future<List<ServiceType>> addAll(List<ServiceType> serviceTypes);
  Future<void> delete(String id);
  Future<List<ServiceType>> get(String userId);
  Future<void> update(ServiceType serviceType);
}
