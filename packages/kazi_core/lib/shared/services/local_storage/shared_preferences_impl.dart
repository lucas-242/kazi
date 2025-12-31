import 'package:flutter/foundation.dart';
import 'package:kazi_core/shared/models/errors.dart';
import 'package:kazi_core/shared/services/local_storage/kazi_local_storage_service.dart';
import 'package:kazi_core/shared/utils/log_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

final class SharedPreferencesImpl implements KaziLocalStorageService {
  @visibleForTesting
  SharedPreferencesImpl.forTest(this._prefs);
  SharedPreferencesImpl._(this._prefs);

  final SharedPreferences _prefs;

  static Future<SharedPreferencesImpl> createInstance() async {
    final prefs = await SharedPreferences.getInstance();
    return SharedPreferencesImpl._(prefs);
  }

  @override
  Future<void> write<T>(String key, T value) {
    try {
      switch (value) {
        case final bool v:
          return _prefs.setBool(key, v);
        case final int v:
          return _prefs.setInt(key, v);
        case final double v:
          return _prefs.setDouble(key, v);
        case final String v:
          return _prefs.setString(key, v);
        default:
          throw ClientError('Invalid parameter to write at Local Storage');
      }
    } catch (e, stackTrace) {
      Log.error(e, stackTrace, 'Error writing to Local Storage');
      throw ClientError('Error writing to Local Storage');
    }
  }

  @override
  Future<T?> read<T>(String key) async {
    try {
      final value = _prefs.get(key);
      return value is T ? value : null;
    } catch (e, stackTrace) {
      Log.error(e, stackTrace, 'Error reading from Local Storage');
      throw ClientError('Error reading from Local Storage');
    }
  }

  @override
  Future<bool> containsKey(String key) async => _prefs.containsKey(key);

  @override
  Future<void> remove(String key) => _prefs.remove(key);

  @override
  Future<void> clear() => _prefs.clear();
}
