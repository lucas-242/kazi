import 'package:kazi/core/services/domain/feature_flag.dart';
import 'package:kazi/core/services/domain/feature_flag_service.dart';

/// Flags resolved from a map, falling back to each flag's own code default.
class FakeFeatureFlagService implements FeatureFlagService {
  FakeFeatureFlagService({
    Map<FeatureFlag, bool> flags = const {},
    this.initError,
  }) : _flags = Map.of(flags);

  final Map<FeatureFlag, bool> _flags;

  /// When set, [init] throws it — for exercising fail-open startup paths.
  final Object? initError;

  bool initCalled = false;

  @override
  Future<void> init() async {
    initCalled = true;
    if (initError != null) throw initError!;
  }

  @override
  bool isEnabled(FeatureFlag flag) => _flags[flag] ?? flag.defaultValue;

  void set(FeatureFlag flag, {required bool enabled}) => _flags[flag] = enabled;
}
