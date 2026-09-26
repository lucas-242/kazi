/// How the clients list is sorted.
///
/// Chosen from `ClientOrderBottomSheet`, opened by the sort icon in the
/// header — the same door and the same shape the Services tab's own
/// `OrderByBottomSheet` uses, so the two lists teach one behaviour.
enum ClientOrder {
  /// "Quem eu vi por último" — the question someone who attends people actually
  /// asks. Replaced an ambiguous "Recentes", which could have meant the date
  /// the client was registered.
  lastService,

  alphabetical,

  /// Lifetime earnings, converted to the profile default on read.
  topEarning,
}
