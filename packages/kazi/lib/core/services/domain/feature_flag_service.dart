import 'package:kazi/core/services/domain/feature_flag.dart';

abstract interface class FeatureFlagService {
  /// Publishes the code defaults and fetches the remote values. Must be awaited
  /// during startup, before the first [isEnabled] read.
  Future<void> init();

  /// Whether [flag] is currently on. Synchronous by design: reads happen in
  /// build methods and controllers, so the values must already be resolved.
  bool isEnabled(FeatureFlag flag);
}
