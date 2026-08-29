import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi_core/kazi_core.dart';

abstract interface class ClientsRepository {
  /// Returns a page of active clients owned by [ownerId], ordered by name. Pass
  /// the last loaded client's name as [startAfterName] to fetch the next page.
  Future<List<ClientEntry>> getClients(
    String ownerId, {
    int limit = 10,
    String? startAfterName,
  });

  /// Returns a page of archived clients owned by [ownerId], ordered by name.
  Future<List<ClientEntry>> getArchivedClients(
    String ownerId, {
    int limit = 20,
    String? startAfterName,
  });

  /// Returns active clients owned by [ownerId] whose name matches [query].
  ///
  /// Matching is a prefix range over the stored name, so it is case- and
  /// accent-sensitive: good enough to warn about a duplicate, never good
  /// enough to block on.
  Future<List<ClientEntry>> searchByName(String ownerId, String query);

  /// The client already on file under [identifier], archived ones included, or
  /// null when the document is new.
  ///
  /// Backs `ClientDocumentRule`, which refuses a save on a repeat — and refuses
  /// it on a failure here too, since not having checked is not the same as
  /// having found nothing. Throwing is therefore a meaningful outcome, not
  /// something to swallow.
  Future<ClientEntry?> findByIdentifier(String ownerId, String identifier);

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

  /// Counts every client owned by [ownerId], archived ones included, to enforce
  /// the freemium client limit — archiving must not free up a slot.
  Future<int> count(String ownerId);

  /// Counts the clients the listing actually shows, for its header.
  Future<int> countActive(String ownerId);

  /// Counts archived clients owned by [ownerId], for the entry into the
  /// archive screen.
  Future<int> countArchived(String ownerId);

  /// Counts the services pointing at [clientId], which decides whether the
  /// client can be deleted for good.
  Future<int> countServicesOf(String ownerId, String clientId);

  Future<void> update(String clientId, User client);

  /// Hides a client from [getClients]/[searchByName] without touching a single
  /// field a service reads. Reversible through [restore], and returns the
  /// moment it was archived. See core/archiving.md.
  Future<DateTime> archive(String clientId);

  Future<void> restore(String clientId);

  /// Removes the document for good. Only ever called for a client no service
  /// points at.
  Future<void> delete(String clientId);

  /// Denormalizes the last performed service onto the client document so the
  /// list card can show it without an extra query.
  Future<void> updateLastService(
    String clientId,
    String serviceName,
    DateTime date,
  );
}
