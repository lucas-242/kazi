import 'dart:convert';

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
  // `getValue` is what any reader that has to tell "unset" from "set to false"
  // uses — `RemoteConfigFeatureFlagService`, the analytics kill switches and
  // `SessionReplayPolicy`. Left unstubbed it hands back a null that those
  // readers dereference, so a test unrelated to Remote Config would fail on it.
  //
  // A key absent from all three maps answers `valueStatic`, which every reader
  // treats as "Remote Config knows nothing" and answers from its code default —
  // the behaviour a test that is not about Remote Config wants.
  when(remoteConfig.getValue(any)).thenAnswer((invocation) {
    final key = invocation.positionalArguments.first as String;
    final raw =
        strings[key] ?? bools[key]?.toString() ?? ints[key]?.toString();
    return raw == null
        ? _remoteConfigValue(null, ValueSource.valueStatic)
        : _remoteConfigValue(utf8.encode(raw), ValueSource.valueRemote);
  });
  return remoteConfig;
}

/// The constructor is `@protected` for implementers of the platform interface.
/// Building one here beats mocking the class: these carry real encoded bytes,
/// so `asBool`/`asInt`/`asString` behave exactly as they do in production.
// ignore: invalid_use_of_protected_member
RemoteConfigValue _remoteConfigValue(List<int>? value, ValueSource source) =>
    RemoteConfigValue(value, source);
