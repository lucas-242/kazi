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

  /// Loads a single client plus its recent service history. [ownerId] is
  /// required to constrain the service-history query to the current user, as
  /// required by the `services` collection security rules.
  Future<ClientEntry?> getClientDetails(String ownerId, String clientId);

  /// Creates a client owned by [ownerId] and returns its new document id.
  Future<String> add(String ownerId, User client);

  Future<void> update(String clientId, User client);

  Future<void> delete(String clientId);

  /// Denormalizes the last performed service onto the client document so the
  /// list card can show it without an extra query.
  Future<void> updateLastService(
    String clientId,
    String serviceName,
    DateTime date,
  );
}
