import 'dart:async';

import 'package:kazi/features/auth/domain/models/app_user.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';

/// In-memory [AuthService] whose signed-in user can be changed mid-test.
///
/// **The `user` setter must stay side-effect free.**
/// `KaziFirebaseAuthService.authStateChanges` maps `userChanges()` and assigns
/// `_authService.user = user` from inside that map — the property is a cache
/// the stream fills, not a second way to publish. A setter that re-emitted
/// would feed that map back into itself and spin forever.
///
/// Use [emit] (or [signInAs]/[signOut]) to drive the stream.
class FakeAuthService implements AuthService {
  FakeAuthService({AppUser? user}) : _user = user;

  final _controller = StreamController<AppUser?>.broadcast();
  AppUser? _user;

  bool signOutCalled = false;

  /// What [signInWithGoogle] reports. Set to false to exercise a cancelled or
  /// failed sign-in.
  bool signInSucceeds = true;

  @override
  AppUser? get user => _user;

  @override
  set user(AppUser? value) => _user = value;

  /// Publishes [value] as an auth change, as the backend would.
  void emit(AppUser? value) {
    _user = value;
    _controller.add(value);
  }

  void signInAs(AppUser value) => emit(value);

  @override
  Future<bool> signInWithGoogle() async {
    if (!signInSucceeds) return false;
    emit(
      _user ??
          AppUser(
            uid: 'signed-in-uid',
            name: 'Signed In',
            email: 'signed@test.com',
          ),
    );
    return true;
  }

  @override
  Future<void> signOut() async {
    signOutCalled = true;
    emit(null);
  }

  /// Replays the current user before the live updates: a broadcast controller
  /// drops anything added while nobody is listening, and every consumer here
  /// subscribes after construction.
  @override
  Stream<AppUser?> userChanges() async* {
    yield _user;
    yield* _controller.stream;
  }

  void dispose() => _controller.close();
}
