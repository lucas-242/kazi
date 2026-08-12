/// A localized label, resolved when it is read rather than when the preset is
/// declared.
///
/// The catalog is a `const` structure built at import time, but
/// `KaziLocalizations.current` is only meaningful once a locale is loaded — and
/// it changes when the user switches language. Holding the getter instead of
/// the string is what keeps a preset correct across both.
typedef PresetLabel = String Function();

/// One service inside a profession kit: a name, a typical price, and whether it
/// is common enough to come already ticked.
class ServicePreset {
  const ServicePreset({
    required this.label,
    required this.brlPrice,
    this.preSelected = false,
  });

  final PresetLabel label;

  /// A typical price **in BRL**, and only usable as such.
  ///
  /// These are informed guesses meant to be recognised and corrected, not
  /// market rates. Outside Brazil they are dropped entirely rather than
  /// converted — see [ProfessionPreset.priceFor].
  final double brlPrice;

  /// Whether the item is ticked when the kit opens. The rest stay visible and
  /// unticked, so including one is a tap instead of a form.
  final bool preSelected;
}
