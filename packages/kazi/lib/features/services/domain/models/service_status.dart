/// Where a service stands: registered and still owed, paid for, or called off.
///
/// Derived from the two stamps a service carries rather than stored on its own
/// — see `Service.status`. A cancelled service is still a record, but it earns
/// nothing: every total in the app leaves it out.
enum ServiceStatus { pending, received, cancelled }
