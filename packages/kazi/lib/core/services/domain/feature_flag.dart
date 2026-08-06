/// Remotely controlled toggles for whole app features.
enum FeatureFlag {
  /// Master switch for the paid tier: the paywall, the subscription entry point
  /// in settings and every freemium limit. When off the app behaves as if
  /// monetization did not exist — nobody is blocked and nobody is asked to pay.
  payments('payments_enabled', defaultValue: true);

  const FeatureFlag(this.key, {required this.defaultValue});

  final String key;
  final bool defaultValue;
}
