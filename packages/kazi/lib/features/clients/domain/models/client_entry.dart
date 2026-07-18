import 'package:kazi_core/kazi_core.dart';

/// Pairs a client's Firestore document id (a `String`) with its [ClientInfo]
/// payload.
///
/// [ClientInfo] reuses kazi_core's [User], whose `id` is an `int` and therefore
/// cannot hold a Firestore auto id. The record carries the real string id used
/// for navigation and CRUD, keeping the reused entities untouched.
typedef ClientEntry = ({String id, ClientInfo info});
