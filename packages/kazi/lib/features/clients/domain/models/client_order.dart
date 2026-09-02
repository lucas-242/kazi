/// How the clients list is sorted.
///
/// Ordering is not filtering: it never hides anyone, which is why it lives in
/// chips above the list rather than in the filter sheet.
enum ClientOrder {
  /// "Quem eu vi por último" — the question someone who attends people actually
  /// asks. Replaced an ambiguous "Recentes", which could have meant the date
  /// the client was registered.
  lastService,

  alphabetical,

  /// Lifetime earnings, converted to the profile default on read.
  topEarning,
}
