/// Access tier a user falls into, derived from their subscription history.
///
/// - [newFree]: never paid for a subscription (includes users who only started
///   the free trial and cancelled). Gets the standard freemium limits.
/// - [churned]: paid for at least one cycle and is now back on the free plan.
///   Gets stricter limits to discourage subscribe-dump-cancel abuse.
/// - [premium]: has an active entitlement (paid or an active trial). No limits,
///   no ads.
enum UserTier { newFree, churned, premium }
