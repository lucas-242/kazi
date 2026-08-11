/// The two representations of the same filtered list of services.
///
/// A view, not a route: both sides read the same services under the same
/// filters, so changing the period moves the list and the charts together.
/// A parallel screen would have had to duplicate the filters and would then
/// have aged apart from them.
enum ServiceView { list, summary }
