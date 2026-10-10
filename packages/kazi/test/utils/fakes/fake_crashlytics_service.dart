import 'package:kazi/core/services/domain/crashlytics_service.dart';

/// Records what would have been reported, so fail-open paths can assert that
/// the failure was swallowed *and* logged.
class FakeCrashlyticsService implements CrashlyticsService {
  final List<Object> loggedExceptions = [];
  final List<StackTrace> loggedTraces = [];
  final List<String?> loggedReasons = [];
  final Map<String, Object> customKeys = {};
  bool initCalled = false;
  String? userId;

  @override
  Future<void> init() async => initCalled = true;

  @override
  void log(Object exception, StackTrace stackTrace, {String? reason}) {
    loggedExceptions.add(exception);
    loggedTraces.add(stackTrace);
    loggedReasons.add(reason);
  }

  @override
  Future<void> setUser(String? userId) async => this.userId = userId;

  @override
  Future<void> setCustomKey(String key, Object value) async =>
      customKeys[key] = value;
}
