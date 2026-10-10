/// Receives a failure that kazi_core handled without surfacing — a fallback
/// taken, a cache dropped — so the app can report it to its crash tool.
///
/// kazi_core has no crash reporter of its own; apps override
/// `kaziErrorReporterProvider` to plug one in. Must not throw.
typedef KaziErrorReporter = void Function(Object error, StackTrace trace);
