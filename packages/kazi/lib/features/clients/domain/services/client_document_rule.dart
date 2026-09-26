import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi/features/clients/domain/repositories/clients_repository.dart';
import 'package:kazi_core/kazi_core.dart';

/// The one place deciding whether a client's document number may be used.
///
/// Two people cannot share one, so a repeat is refused outright — unlike a
/// namesake, which is legitimate and only warns. Both the client form and the
/// service form's quick-add go through here, or the quick-add would be a way
/// around the rule. See core/archiving.md.
abstract final class ClientDocumentRule {
  /// Throws [ClientError] when another client already carries [identifier].
  ///
  /// An empty document is always free — the field is optional. Pass
  /// [excludeClientId] when editing, or the client would collide with itself.
  ///
  /// A lookup that throws refuses the save too, as [ExternalError], with a
  /// message saying the check failed rather than that a duplicate exists. Not
  /// being able to verify is not the same as having verified — letting the save
  /// through would put the duplicate in silently, which is the outcome the rule
  /// exists to prevent.
  static Future<void> ensureFree(
    ClientsRepository repository, {
    required String ownerId,
    required String identifier,
    String? excludeClientId,
  }) async {
    final trimmed = identifier.trim();
    if (trimmed.isEmpty) return;

    final ClientEntry? existing;
    try {
      existing = await repository.findByIdentifier(ownerId, trimmed);
    } catch (_) {
      // The repository already logged it; what reaches the user has to say the
      // check failed, not that their client's data is wrong.
      throw ExternalError(KaziLocalizations.current.errorToVerifyDocument);
    }

    if (existing == null || existing.id == excludeClientId) return;

    final name = existing.info.user.name;
    throw ClientError(
      existing.archivedAt != null
          ? KaziLocalizations.current.clientSameDocumentArchived(name)
          : KaziLocalizations.current.clientSameDocument(name),
    );
  }
}
