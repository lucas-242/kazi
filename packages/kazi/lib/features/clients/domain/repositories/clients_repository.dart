import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi/features/services/domain/models/service.dart';
import 'package:kazi_core/kazi_core.dart' hide Service;

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
  /// Every active client, unpaged.
  ///
  /// The listing orders by figures Firestore cannot compute — lifetime
  /// earnings live as a per-currency map and only the app holds the rates — so
  /// the ordering happens in memory and needs the whole set. Bounded in
  /// practice by the freemium limits. See core/counters.md.
  Future<List<ClientEntry>> getAllActiveClients(String ownerId);

  Future<List<ClientEntry>> searchByName(String ownerId, String query);

  /// The client already on file under [identifier], archived ones included, or
  /// null when the document is new.
  ///
  /// Backs `ClientDocumentRule`, which refuses a save on a repeat — and refuses
  /// it on a failure here too, since not having checked is not the same as
  /// having found nothing. Throwing is therefore a meaningful outcome, not
  /// something to swallow.
  Future<ClientEntry?> findByIdentifier(String ownerId, String identifier);

  /// Loads a single client. Its service history is a separate query — see
  /// [getServiceHistory].
  Future<ClientEntry?> getClientDetails(String ownerId, String clientId);

  /// Returns a page of a client's service history, newest first. Pass the last
  /// loaded service's date as [startAfterDate] to fetch the next page.
  ///
  /// Whole services rather than a projection of them: the ficha renders the
  /// same row the services list does, and that row needs the value, the
  /// commission and the catalog item's colour. [ownerId] constrains the query
  /// to the current user, as the `services` collection rules require.
  Future<List<Service>> getServiceHistory(
    String ownerId,
    String clientId, {
    int limit,
    DateTime? startAfterDate,
  });

  /// The date of the **oldest** service performed for [clientId], or null when
  /// there is none.
  ///
  /// This is what "cliente desde" reads: the day the person actually became a
  /// client, which predates the record whenever the history was entered after
  /// the fact. Only asked for when the loaded page does not already reach the
  /// end of the history.
  Future<DateTime?> getFirstServiceDate(String ownerId, String clientId);

  /// Creates a client owned by [ownerId] and returns its new document id.
  Future<String> add(String ownerId, User client, {String observation});

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

  Future<void> update(String clientId, User client, {String observation});

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
