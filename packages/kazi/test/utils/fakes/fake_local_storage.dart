import 'package:kazi_core/kazi_core.dart'
    hide Service, ServiceType, ServiceTypeRepository;

/// In-memory [KaziLocalStorageService].
///
/// Preferred over `SharedPreferences.setMockInitialValues` because the values
/// stay inspectable from the test, and nothing leaks between test cases.
class FakeLocalStorage implements KaziLocalStorageService {
  FakeLocalStorage([Map<String, Object?> initialValues = const {}])
    : values = Map.of(initialValues);

  final Map<String, Object?> values;

  @override
  Future<void> clear() async => values.clear();

  @override
  Future<bool> containsKey(String key) async => values.containsKey(key);

  @override
  Future<T?> read<T>(String key) async => values[key] as T?;

  @override
  Future<void> remove(String key) async => values.remove(key);

  @override
  Future<void> write<T>(String key, T value) async => values[key] = value;
}
