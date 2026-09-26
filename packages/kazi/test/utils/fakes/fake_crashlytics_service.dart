import 'package:kazi/core/services/domain/crashlytics_service.dart';

/// Records what would have been reported, so fail-open paths can assert that
/// the failure was swallowed *and* logged.
class FakeCrashlyticsService implements CrashlyticsService {
  final List<Object> loggedExceptions = [];
  final Map<String, Object> customKeys = {};
  bool initCalled = false;
  String? userId;

  @override
  Future<void> init() async => initCalled = true;

  @override
  void log(Object exception, StackTrace stackTrace) =>
      loggedExceptions.add(exception);

  @override
  Future<void> setUser(String? userId) async => this.userId = userId;

  @override
  Future<void> setCustomKey(String key, Object value) async =>
      customKeys[key] = value;
}
