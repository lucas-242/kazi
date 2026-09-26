import 'package:kazi/features/clients/domain/models/client_entry.dart';
import 'package:kazi/features/clients/domain/repositories/clients_repository.dart';
import 'package:kazi_core/kazi_core.dart';

/// The one place deciding whether a name is already taken by another client.
///
/// A namesake **never blocks**: two people legitimately share a name, and only
/// the user knows whether two records are one person. A repeated *document*
/// does block — that is [ClientDocumentRule], and the two are deliberately
/// different rules. The client form and the service form's quick-add both come
/// through here, or the quick-add would be the way around the warning.
abstract final class ClientNamesakeRule {
  /// The active client already carrying [name], or null when there is none.
  ///
  /// Null is also what a failed lookup yields: a warning that could not run is
  /// not a reason to cost the user their typing.
  ///
  /// Two documents, both filled and different, settle it — the shared name is
  /// a coincidence and these are two people. Saying otherwise would train the
  /// user to dismiss the warning.
  ///
  /// The search is a prefix query over the stored name, so it is case- and
  /// accent-sensitive and cannot reach a namesake saved under different
  /// casing; the normalized comparison here catches what does come back. Best
  /// effort by design. See core/archiving.md.
  static Future<ClientEntry?> find(
    ClientsRepository repository, {
    required String ownerId,
    required String name,
    String identifier = '',
    String? excludeClientId,
  }) async {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return null;

    try {
      final matches = await repository.searchByName(ownerId, trimmedName);
      final normalized = trimmedName.normalizedName;
      final document = identifier.trim();

      for (final match in matches) {
        if (match.id == excludeClientId) continue;
        if (match.info.user.name.normalizedName != normalized) continue;

        final theirDocument = match.info.user.document.trim();
        if (document.isNotEmpty &&
            theirDocument.isNotEmpty &&
            document != theirDocument) {
          continue;
        }

        return match;
      }

      return null;
    } catch (_) {
      return null;
    }
  }
}
