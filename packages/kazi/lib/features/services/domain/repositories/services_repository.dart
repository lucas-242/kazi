import 'package:kazi/features/services/domain/models/service.dart';

abstract interface class ServicesRepository {
  Future<List<Service>> add(Service service, [int quantity = 1]);
  Future<void> delete(String id);
  Future<List<Service>> get(
    String userId,
    DateTime startDate, [
    DateTime? endDate,
  ]);
  Future<void> update(Service service);
  Future<int> count(String userId, [String? typeId]);

  /// Counts services whose immutable `createdAt` timestamp is on or after
  /// [since]. Used to enforce the monthly freemium limit.
  Future<int> countCreatedSince(String userId, DateTime since);
}
