import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kazi/core/environment/environment.dart';
import 'package:kazi/core/extensions/extensions.dart';
import 'package:kazi/core/services/domain/crashlytics_service.dart';
import 'package:kazi/features/auth/domain/models/app_user.dart';
import 'package:kazi/features/auth/domain/models/sign_in_provider.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi_core/kazi_core.dart'
    hide User, Service, CatalogItem, CatalogItemRepository;

import 'errors/firebase_sign_in_error.dart';

class FirebaseAuthService extends AuthService {
  FirebaseAuthService({
    GoogleSignIn? googleSignIn,
    FirebaseAuth? firebaseAuth,
    AppUser? user,
    required this.crashlyticsService,
  }) : googleSignIn = googleSignIn ?? GoogleSignIn.instance,
       firebaseAuth = firebaseAuth ?? FirebaseAuth.instance {
    this.user = user;
    _initializeGoogleSignIn();
  }
  final GoogleSignIn googleSignIn;
  final FirebaseAuth firebaseAuth;
  final CrashlyticsService crashlyticsService;

  /// What FlutterFire reports when the Apple sheet is dismissed.
  static const _appleCanceledCode = 'canceled';

  /// Captured by [reauthenticate] for [deleteAccount] to revoke. Single-use,
  /// and Apple expires it after five minutes.
  String? _appleAuthorizationCode;

  Future<void> _initializeGoogleSignIn() async {
    // The environment is loaded during app bootstrap. When it isn't (e.g. in
    // tests) there's no server client id to configure, so skip initialization.
    if (!Environment.isLoaded) return;
    await googleSignIn.initialize(
      serverClientId: Environment.instance.googleServerClientId,
    );
  }

  @override
  Future<bool> signIn(SignInProvider provider) async {
    try {
      final response = switch (provider) {
        SignInProvider.google => await firebaseAuth.signInWithCredential(
          await _googleCredential(),
        ),
        SignInProvider.apple => await firebaseAuth.signInWithProvider(
          _appleProvider(),
        ),
      };
      user = response.user?.toAppUser();
      return true;
    } on FirebaseAuthException catch (error, trace) {
      if (error.code == _appleCanceledCode) return false;
      Log.error(error.message, trace);
      crashlyticsService.log(error, trace);
      throw FirebaseSignInError.fromCode(error.code);
    } catch (error, trace) {
      Log.error(error, trace);
      crashlyticsService.log(error, trace);
      return false;
    }
  }

  Future<AuthCredential> _googleCredential() async {
    final googleUser = await googleSignIn.authenticate();
    return GoogleAuthProvider.credential(
      idToken: googleUser.authentication.idToken,
    );
  }

  AppleAuthProvider _appleProvider() => AppleAuthProvider()
    ..addScope('email')
    ..addScope('name');

  SignInProvider _providerOf(User user) {
    final providerIds = user.providerData.map((info) => info.providerId);
    return SignInProvider.values.firstWhere(
      (provider) => providerIds.contains(provider.providerId),
      orElse: () => SignInProvider.google,
    );
  }

  @override
  Future<bool> reauthenticate() async {
    final currentUser = firebaseAuth.currentUser;
    if (currentUser == null) return false;

    try {
      switch (_providerOf(currentUser)) {
        case SignInProvider.google:
          await currentUser.reauthenticateWithCredential(
            await _googleCredential(),
          );
        case SignInProvider.apple:
          final response = await currentUser.reauthenticateWithProvider(
            _appleProvider(),
          );
          _appleAuthorizationCode =
              response.additionalUserInfo?.authorizationCode;
      }
      return true;
    } on GoogleSignInException catch (error, trace) {
      if (error.code == GoogleSignInExceptionCode.canceled) return false;
      Log.error(error, trace);
      crashlyticsService.log(error, trace);
      throw FirebaseSignInError();
    } on FirebaseAuthException catch (error, trace) {
      if (error.code == _appleCanceledCode) return false;
      Log.error(error.message, trace);
      crashlyticsService.log(error, trace);
      throw FirebaseSignInError.fromCode(error.code);
    } catch (error, trace) {
      Log.error(error, trace);
      crashlyticsService.log(error, trace);
      throw FirebaseSignInError();
    }
  }

  @override
  Future<void> deleteAccount() async {
    final currentUser = firebaseAuth.currentUser;
    final provider = currentUser == null ? null : _providerOf(currentUser);

    // Must precede the deletion: on iOS, revoking with nobody signed in never
    // completes, and the deletion would hang on it.
    if (provider == SignInProvider.apple) await _revokeAppleGrant();

    try {
      await currentUser?.delete();
      user = null;
    } on FirebaseAuthException catch (error, trace) {
      Log.error(error.message, trace);
      crashlyticsService.log(error, trace);
      throw FirebaseSignInError.fromCode(error.code);
    } catch (error, trace) {
      Log.error(error, trace);
      crashlyticsService.log(error, trace);
      throw FirebaseSignInError();
    }

    if (provider == SignInProvider.google) await _revokeGoogleGrant();
  }

  /// A failed revoke is only logged: the account deletion matters more than
  /// the grant it leaves behind, which opens nothing once the account is gone.
  Future<void> _revokeAppleGrant() async {
    final authorizationCode = _appleAuthorizationCode;
    _appleAuthorizationCode = null;

    try {
      if (authorizationCode == null) {
        throw StateError('No Apple authorization code to revoke');
      }
      await firebaseAuth.revokeTokenWithAuthorizationCode(authorizationCode);
    } catch (error, trace) {
      Log.error(error, trace);
      crashlyticsService.log(error, trace);
    }
  }

  Future<void> _revokeGoogleGrant() async {
    try {
      await googleSignIn.disconnect();
    } catch (error, trace) {
      Log.error(error, trace);
      crashlyticsService.log(error, trace);
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await googleSignIn.signOut();
      await firebaseAuth.signOut();
      user = null;
    } on FirebaseAuthException catch (error, trace) {
      Log.error(error.message, trace);
      crashlyticsService.log(error, trace);
      throw FirebaseSignInError.fromCode(error.code);
    } catch (error, trace) {
      Log.error(error, trace);
      crashlyticsService.log(error, trace);
      throw FirebaseSignInError();
    }
  }

  @override
  Stream<AppUser?> userChanges() {
    return firebaseAuth.userChanges().map((user) => user?.toAppUser());
  }
}
