/// A stored minute count as a [Duration]. Zero, negative or non-numeric values
/// read as unset: a service of no length has no place on an agenda.
Duration? durationFromMinutes(Object? minutes) =>
    minutes is num && minutes > 0 ? Duration(minutes: minutes.toInt()) : null;
