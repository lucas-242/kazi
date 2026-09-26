import 'package:firebase_core/firebase_core.dart';
import 'package:kazi/core/environment/environment.dart';
import 'package:kazi/firebase_options.dart' as prod;
import 'package:kazi/firebase_options_staging.dart' as staging;
import 'package:kazi_core/kazi_core.dart';

class FirebaseWrapper {
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: Environment.instance.flavor == Flavor.staging
              ? staging.DefaultFirebaseOptions.currentPlatform
              : prod.DefaultFirebaseOptions.currentPlatform,
        );
      }
      _isInitialized = true;
    } catch (e) {
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('duplicate-app') ||
          errorMessage.contains('already exists') ||
          errorMessage.contains('firebase app')) {
        _isInitialized = true;
      } else {
        rethrow;
      }
    }
  }

  static void reset() {
    _isInitialized = false;
  }

  static bool get isInitialized => _isInitialized;
}
