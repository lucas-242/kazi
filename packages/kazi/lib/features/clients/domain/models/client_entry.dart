import 'package:kazi_core/kazi_core.dart';

/// Pairs a client's Firestore document id (a `String`) with its [ClientInfo]
/// payload.
///
/// [ClientInfo] reuses kazi_core's [User], whose `id` is an `int` and therefore
/// cannot hold a Firestore auto id. The record carries the real string id used
/// for navigation and CRUD, keeping the reused entities untouched.
typedef ClientEntry = ({String id, ClientInfo info});

/// [User.birthDate] is non-nullable, so "no birth date" has to be spelled as a
/// value. This is that value, and the only way to ask about it.
///
/// It must be tested by equality, never by comparing the year: most clients
/// were born before it.
abstract final class ClientBirthDate {
  static DateTime get missing => DateTime(2000);

  static bool isMissing(DateTime? birthDate) =>
      birthDate == null || birthDate == missing;
}
