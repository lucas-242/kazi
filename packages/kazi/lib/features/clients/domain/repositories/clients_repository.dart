import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi_core/kazi_core.dart';

abstract interface class ClientsRepository {
  /// Returns a page of clients owned by [ownerId], ordered by name. Pass the
  /// last loaded client's name as [startAfterName] to fetch the next page.
  Future<List<ClientEntry>> getClients(
    String ownerId, {
    int limit = 10,
    String? startAfterName,
  });

  /// Returns clients owned by [ownerId] whose name matches [query].
  Future<List<ClientEntry>> searchByName(String ownerId, String query);

  /// Loads a single client plus the first page of its service history.
  /// [ownerId] is required to constrain the service-history query to the
  /// current user, as required by the `services` collection security rules.
  /// Use [getServiceHistory] to fetch the following pages.
  Future<ClientEntry?> getClientDetails(
    String ownerId,
    String clientId, {
    int limit,
  });

  /// Returns a page of a client's service history, newest first. Pass the last
  /// loaded item's date as [startAfterDate] to fetch the next page.
  Future<List<ServiceHistoryItem>> getServiceHistory(
    String ownerId,
    String clientId, {
    int limit,
    DateTime? startAfterDate,
  });

  /// Creates a client owned by [ownerId] and returns its new document id.
  Future<String> add(String ownerId, User client);

  /// Counts active clients owned by [ownerId]. Used to enforce the freemium
  /// client limit.
  Future<int> count(String ownerId);

  Future<void> update(String clientId, User client);

  /// Soft-deletes a client: keeps the document (so the `services` history stays
  /// referentially intact) while flagging it inactive and wiping all personal
  /// data. Deactivated clients no longer appear in [getClients]/[searchByName].
  Future<void> deactivate(String clientId);

  /// Denormalizes the last performed service onto the client document so the
  /// list card can show it without an extra query.
  Future<void> updateLastService(
    String clientId,
    String serviceName,
    DateTime date,
  );
}
