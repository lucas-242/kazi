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

  /// Stamps [ids] as paid on [receivedAt], or clears the stamp when it is null.
  ///
  /// Field-scoped rather than a full [update], so marking a service as received
  /// can never clobber a concurrent edit to its value or date — and so the
  /// exchange-rate anchor is structurally out of reach.
  ///
  /// Serves both the bulk action and the single toggle, which is why it takes a
  /// list. Not atomic across chunks; see the implementation.
  Future<void> setReceivedAt(List<String> ids, DateTime? receivedAt);

  Future<int> count(String userId, [String? typeId]);

  /// Counts services whose immutable `createdAt` timestamp is on or after
  /// [since]. Used to enforce the monthly freemium limit.
  Future<int> countCreatedSince(String userId, DateTime since);
}
