import 'package:kazi/features/onboarding/domain/models/service_preset.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// A starter kit for one profession: the services it usually sells, what they
/// usually cost, and how much of that the worker usually keeps.
///
/// This is the single biggest lever in the setup. Picking a profession seeds a
/// working catalog in three taps, replacing five minutes of typing demanded
/// before the app has delivered anything — the worst possible place to ask for
/// effort.
class ProfessionPreset {
  const ProfessionPreset({
    required this.key,
    required this.label,
    required this.defaultCommissionPercent,
    required this.services,
    this.synonyms = const [],
  });

  /// Stable identifier, persisted on the user document and used in analytics.
  /// Never localized and never renamed — a new kit gets a new key.
  final String key;

  final PresetLabel label;

  /// The share the worker keeps, as a percentage. Salon-based trades start at
  /// 40–50, self-employed ones at 100 — which leaves the commission step
  /// almost answered and spares self-employed users a question many of them
  /// cannot parse.
  final double defaultCommissionPercent;

  final List<ServicePreset> services;

  /// Search terms that resolve to this kit, in every language the app speaks.
  /// Lowercase and unaccented; matching normalizes the query the same way.
  final List<String> synonyms;

  /// The price to seed for [service] given the user's currency.
  ///
  /// Null outside BRL, and null is exactly right: the field opens blank,
  /// waiting for a local amount. Converting R$ 180 into dollars would put a
  /// meaningless number on the second screen and cost the trust the whole app
  /// is selling.
  double? priceFor(ServicePreset service, SupportedCurrency currency) =>
      currency == SupportedCurrency.brl ? service.brlPrice : null;
}
