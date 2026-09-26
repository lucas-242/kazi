/// The quick cuts of the catalogue, as chips above the list.
///
/// A filter, unlike an ordering, hides rows — which is why "sem comissão"
/// belongs here: it is a shortcut to a problem worth fixing, not a way of
/// reading the whole catalogue.
enum CatalogFilter {
  all,

  /// Ordered by how many services carry the item, most first.
  mostUsed,

  /// Items with no commission configured. They enter the generated total and
  /// not the user's, which is the gap the home's nudge is about.
  withoutCommission,
}
