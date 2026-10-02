import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kazi/core/environment/environment.dart';
import 'package:kazi/core/extensions/extensions.dart';
import 'package:kazi/core/services/domain/crashlytics_service.dart';
import 'package:kazi/features/auth/domain/models/app_user.dart';
import 'package:kazi/features/auth/domain/services/auth_service.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

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

  Future<void> _initializeGoogleSignIn() async {
    // The environment is loaded during app bootstrap. When it isn't (e.g. in
    // tests) there's no server client id to configure, so skip initialization.
    if (!Environment.isLoaded) return;
    await googleSignIn.initialize(
      serverClientId: Environment.instance.googleServerClientId,
    );
  }

  @override
  Future<bool> signInWithGoogle() async {
    try {
      final credential = await _googleCredential();
      final response = await firebaseAuth.signInWithCredential(credential);
      user = response.user?.toAppUser();
      return true;
    } on FirebaseAuthException catch (error, trace) {
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

  @override
  Future<bool> reauthenticate() async {
    final currentUser = firebaseAuth.currentUser;
    if (currentUser == null) return false;

    try {
      final credential = await _googleCredential();
      await currentUser.reauthenticateWithCredential(credential);
      return true;
    } on GoogleSignInException catch (error, trace) {
      if (error.code == GoogleSignInExceptionCode.canceled) return false;
      Log.error(error, trace);
      crashlyticsService.log(error, trace);
      throw FirebaseSignInError();
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
  Future<void> deleteAccount() async {
    try {
      await firebaseAuth.currentUser?.delete();
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

    // The account is already gone, so a failed revoke is only logged: the
    // grant it leaves behind opens nothing.
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
