import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kazi/app/models/app_user.dart';
import 'package:kazi/app/services/auth_service/auth_service.dart';
import 'package:kazi/app/services/crashlytics_service/crashlytics_service.dart';
import 'package:kazi/app/shared/constants/firebase_config.dart';
import 'package:kazi/app/shared/extensions/extensions.dart';
import 'package:kazi/app/shared/utils/log_utils.dart';

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
    await googleSignIn.initialize(
      serverClientId: FirebaseConfig.serverClientId,
    );
  }

  @override
  Future<bool> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await googleSignIn.authenticate();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final response = await firebaseAuth.signInWithCredential(credential);
      user = response.user?.toAppUser();
      return true;
    } on FirebaseAuthException catch (error, trace) {
      Log.error(error.message);
      crashlyticsService.log(error, trace);
      throw FirebaseSignInError.fromCode(
        error.code,
        error.stackTrace?.toString(),
      );
    } catch (error, trace) {
      Log.error(error);
      crashlyticsService.log(error, trace);
      return false;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await googleSignIn.signOut();
      await firebaseAuth.signOut();
      user = null;
    } on FirebaseAuthException catch (error, trace) {
      Log.error(error.message);
      crashlyticsService.log(error, trace);
      throw FirebaseSignInError.fromCode(
        error.code,
        error.stackTrace?.toString(),
      );
    } catch (error, trace) {
      Log.error(error);
      crashlyticsService.log(error, trace);
      throw FirebaseSignInError();
    }
  }

  @override
  Stream<AppUser?> userChanges() {
    return firebaseAuth.userChanges().map((user) => user?.toAppUser());
  }
}
