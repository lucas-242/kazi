/// Where a service stands on the agenda at a given moment. Derived by
/// `Service.scheduleStateAt`, never stored. See services/README.md.
enum ScheduleState {
  /// Registered without a start time. Never [overdue]: legacy services are
  /// all untimed, and none of them is late.
  untimed,
  upcoming,
  inProgress,

  /// Past its end and not marked finished.
  overdue,
  finished,
  cancelled,
}
