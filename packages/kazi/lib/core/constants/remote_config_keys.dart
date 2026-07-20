abstract class RemoteConfigKeys {
  static const String minRequiredVersion = 'min_required_version';
  static const String latestVersion = 'latest_version';

  static Map<String, dynamic> get defaults => {
    minRequiredVersion: '0.0.0',
    latestVersion: '0.0.0',
  };
}
