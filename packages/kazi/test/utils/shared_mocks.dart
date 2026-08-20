import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'shared_mocks.mocks.dart';

/// Mocks shared across the suite, generated once here instead of being
/// re-declared per test file.
@GenerateMocks([FirebaseRemoteConfig])
// ignore: unused_element
void _generate() {}

/// A [FirebaseRemoteConfig] that answers with the code defaults.
///
/// `getInt` returning 0 is what makes the ad policies fall back to their own
/// defaults, which is the behaviour every test that is not about Remote Config
/// wants.
MockFirebaseRemoteConfig stubRemoteConfig({
  Map<String, int> ints = const {},
  Map<String, bool> bools = const {},
  Map<String, String> strings = const {},
}) {
  final remoteConfig = MockFirebaseRemoteConfig();
  when(remoteConfig.getInt(any)).thenAnswer(
    (invocation) => ints[invocation.positionalArguments.first as String] ?? 0,
  );
  when(remoteConfig.getBool(any)).thenAnswer(
    (invocation) =>
        bools[invocation.positionalArguments.first as String] ?? false,
  );
  when(remoteConfig.getString(any)).thenAnswer(
    (invocation) =>
        strings[invocation.positionalArguments.first as String] ?? '',
  );
  return remoteConfig;
}
