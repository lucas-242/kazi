// The hand-written mocks below implement `@immutable` Firebase and Google
// classes, which makes the analyzer demand final fields — and the ones it names
// (`Mock._givenName` and friends) belong to mockito's own base class, which no
// test can change.
// ignore_for_file: must_be_immutable
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kazi/core/services/domain/crashlytics_service.dart';
import 'package:kazi/features/auth/data/services/errors/firebase_sign_in_error.dart';
import 'package:kazi/features/auth/data/services/firebase_auth_service.dart';
import 'package:kazi/features/auth/domain/models/sign_in_provider.dart';
import 'package:kazi_core/kazi_core.dart'
    hide User, Service, CatalogItem, CatalogItemRepository;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import '../../../../../mocks/mocks.dart';
import '../../../../../utils/test_helper.dart';
import '../../../../../utils/test_matchers.dart';
import 'firebase_auth_service_test.mocks.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {
  MockFirebaseAuth({
    this.isSignedIn = false,
    User? signedInUser,
    this.providerSignInError,
    List<String>? calls,
  }) : _signedInUser = signedInUser,
       calls = calls ?? [];
  final bool isSignedIn;
  final User? _signedInUser;
  final FirebaseAuthException? providerSignInError;

  /// The provider sign-ins and token revocations, in order.
  final List<String> calls;

  @override
  Future<UserCredential> signInWithCredential(AuthCredential? credential) =>
      Future.value(_userCredential);

  @override
  Future<UserCredential> signInWithProvider(AuthProvider provider) async {
    if (providerSignInError case final error?) throw error;
    calls.add('signInWithProvider:${provider.providerId}');
    return _userCredential;
  }

  @override
  Future<void> revokeTokenWithAuthorizationCode(
    String authorizationCode,
  ) async {
    calls.add('revoke:$authorizationCode');
  }

  @override
  Future<UserCredential> signOut() => Future.value(_userCredential);

  @override
  User? get currentUser => isSignedIn ? _signedInUser ?? _user : null;

  @override
  Stream<User?> userChanges() {
    return Stream.value(currentUser);
  }
}

class MockUser extends Mock implements User {
  @override
  bool get isAnonymous => false;

  @override
  String get uid => userMock.uid;

  @override
  String? get email => userMock.email;

  @override
  String? get displayName => userMock.name;

  @override
  List<UserInfo> get providerData => [];

  /// `metadata` is non-nullable on the real `User`, so leaving it unstubbed
  /// makes mockito hand back a null that `toAppUser` then dereferences. The
  /// constructor is `@protected` for implementers of the platform interface;
  /// building one here is the only way to give the mock a creation date, which
  /// the analytics account-age cohort reads.
  // ignore: invalid_use_of_protected_member
  @override
  UserMetadata get metadata => UserMetadata(
    DateTime.utc(2024).millisecondsSinceEpoch,
    DateTime.utc(2024, 6).millisecondsSinceEpoch,
  );
}

class FakeUserInfo extends Mock implements UserInfo {
  FakeUserInfo(this.providerId);

  @override
  final String providerId;
}

/// Records the account-level calls and fails them on demand.
class RecordingUser extends MockUser {
  RecordingUser({
    this.reauthenticateError,
    this.deleteError,
    this.providerIds = const ['google.com'],
    this.appleAuthorizationCode = 'apple-code',
    List<String>? calls,
  }) : calls = calls ?? [];

  final FirebaseAuthException? reauthenticateError;
  final FirebaseAuthException? deleteError;
  final List<String> providerIds;
  final String? appleAuthorizationCode;

  /// Shared with [MockFirebaseAuth.calls] to check what ran first.
  final List<String> calls;

  AuthCredential? reauthenticatedWith;
  AuthProvider? reauthenticatedWithProvider;
  bool deleted = false;

  @override
  List<UserInfo> get providerData => providerIds.map(FakeUserInfo.new).toList();

  @override
  Future<UserCredential> reauthenticateWithProvider(
    AuthProvider provider,
  ) async {
    if (reauthenticateError case final error?) throw error;
    reauthenticatedWithProvider = provider;
    final credential = MockUserCredential();
    when(credential.additionalUserInfo).thenReturn(
      // ignore: invalid_use_of_protected_member
      AdditionalUserInfo(
        isNewUser: false,
        authorizationCode: appleAuthorizationCode,
      ),
    );
    return credential;
  }

  @override
  Future<UserCredential> reauthenticateWithCredential(
    AuthCredential credential,
  ) async {
    if (reauthenticateError case final error?) throw error;
    reauthenticatedWith = credential;
    return _userCredential;
  }

  @override
  Future<void> delete() async {
    if (deleteError case final error?) throw error;
    calls.add('delete');
    deleted = true;
  }
}

class MockGoogleSignInAuthentication extends Mock
    implements GoogleSignInAuthentication {
  @override
  String? get idToken => 'abc123';
}

final _userCredential = MockUserCredential();
final _user = MockUser();

@GenerateMocks([
  GoogleSignIn,
  GoogleSignInAccount,
  CrashlyticsService,
  UserCredential,
])
void main() {
  late MockGoogleSignIn googleSignIn;
  late MockGoogleSignInAccount googleSignInAccount;
  late MockGoogleSignInAuthentication googleSignInAuthentication;
  late FirebaseAuthService authService;
  late MockFirebaseAuth firebaseAuth;
  late MockCrashlyticsService crashlyticsService;

  setUpAll(() {
    TestHelper.loadAppLocalizations();
  });

  setUp(() {
    googleSignIn = MockGoogleSignIn();
    googleSignInAccount = MockGoogleSignInAccount();
    googleSignInAuthentication = MockGoogleSignInAuthentication();
    firebaseAuth = MockFirebaseAuth();
    crashlyticsService = MockCrashlyticsService();
    authService = FirebaseAuthService(
      googleSignIn: googleSignIn,
      firebaseAuth: firebaseAuth,
      crashlyticsService: crashlyticsService,
    );
  });

  group('Sign in', () {
    test('Should return true when sign in with google', (() async {
      when(
        googleSignIn.authenticate(),
      ).thenAnswer((_) async => googleSignInAccount);

      when(
        googleSignInAccount.authentication,
      ).thenReturn(googleSignInAuthentication);

      when(_userCredential.user).thenReturn(_user);

      final isSignedIn = await authService.signIn(SignInProvider.google);
      expect(isSignedIn, isTrue);
    }));

    test(
      'Should return false when dismiss sign in with google popup',
      (() async {
        when(
          googleSignIn.authenticate(),
        ).thenThrow(Exception('User cancelled'));

        final isSignedIn = await authService.signIn(SignInProvider.google);
        expect(isSignedIn, isFalse);
      }),
    );

    test(
      'Should throws FirebaseSignInError with invalid credential message when throw FirebaseAuthException',
      (() async {
        when(
          googleSignIn.authenticate(),
        ).thenThrow(FirebaseAuthException(code: 'invalid-credential'));

        expect(
          authService.signIn(SignInProvider.google),
          ErrorWithMessage<FirebaseSignInError>(
            KaziLocalizations.current.errorCredentialIsInvalid,
          ),
        );
      }),
    );
  });

  group('Sign in with Apple', () {
    test('signs in through the native Apple provider', () async {
      when(_userCredential.user).thenReturn(_user);

      final isSignedIn = await authService.signIn(SignInProvider.apple);

      expect(isSignedIn, isTrue);
      expect(firebaseAuth.calls, ['signInWithProvider:apple.com']);
      verifyNever(googleSignIn.authenticate());
    });

    test('returns false when the Apple sheet is dismissed', () async {
      authService = FirebaseAuthService(
        googleSignIn: googleSignIn,
        firebaseAuth: MockFirebaseAuth(
          providerSignInError: FirebaseAuthException(code: 'canceled'),
        ),
        crashlyticsService: crashlyticsService,
      );

      expect(await authService.signIn(SignInProvider.apple), isFalse);
    });

    test('explains an e-mail already registered through Google', () async {
      authService = FirebaseAuthService(
        googleSignIn: googleSignIn,
        firebaseAuth: MockFirebaseAuth(
          providerSignInError: FirebaseAuthException(
            code: 'account-exists-with-different-credential',
          ),
        ),
        crashlyticsService: crashlyticsService,
      );

      expect(
        authService.signIn(SignInProvider.apple),
        ErrorWithMessage<FirebaseSignInError>(
          KaziLocalizations.current.errorThereIsAnotherAccount,
        ),
      );
    });
  });

  group('Sign out', () {
    test('Should sign out with google', (() async {
      firebaseAuth = MockFirebaseAuth(isSignedIn: true);
      authService = FirebaseAuthService(
        googleSignIn: googleSignIn,
        firebaseAuth: firebaseAuth,
        user: userMock,
        crashlyticsService: crashlyticsService,
      );

      expect(authService.user, isNotNull);

      when(googleSignIn.signOut()).thenAnswer((_) async {});
      await authService.signOut();

      expect(authService.user, null);
    }));

    test(
      'Should throws FirebaseSignInError with emailIsInvalid error message when throw FirebaseAuthException',
      (() async {
        when(
          googleSignIn.signOut(),
        ).thenThrow(FirebaseAuthException(code: 'invalid-email'));

        expect(
          authService.signOut(),
          ErrorWithMessage<FirebaseSignInError>(
            KaziLocalizations.current.errorEmailIsInvalid,
          ),
        );
      }),
    );

    test(
      'Should throws FirebaseSignInError with unknowError error message when throw Exception',
      (() async {
        when(googleSignIn.signOut()).thenThrow(Exception());

        expect(
          authService.signOut(),
          ErrorWithMessage<FirebaseSignInError>(
            KaziLocalizations.current.errorUnknowError,
          ),
        );
      }),
    );
  });

  FirebaseAuthService signedInAs(User user, {List<String>? calls}) =>
      FirebaseAuthService(
        googleSignIn: googleSignIn,
        firebaseAuth: MockFirebaseAuth(
          isSignedIn: true,
          signedInUser: user,
          calls: calls,
        ),
        user: userMock,
        crashlyticsService: crashlyticsService,
      );

  void stubGooglePicker() {
    when(
      googleSignIn.authenticate(),
    ).thenAnswer((_) async => googleSignInAccount);
    when(
      googleSignInAccount.authentication,
    ).thenReturn(googleSignInAuthentication);
  }

  group('Reauthenticate', () {
    test(
      'reauthenticates the signed-in user with a fresh credential',
      () async {
        final user = RecordingUser();
        stubGooglePicker();

        final confirmed = await signedInAs(user).reauthenticate();

        expect(confirmed, isTrue);
        expect(user.reauthenticatedWith, isNotNull);
      },
    );

    test('returns false when the Google picker is cancelled', () async {
      final user = RecordingUser();
      when(googleSignIn.authenticate()).thenThrow(
        const GoogleSignInException(code: GoogleSignInExceptionCode.canceled),
      );

      final confirmed = await signedInAs(user).reauthenticate();

      expect(confirmed, isFalse);
      expect(user.reauthenticatedWith, isNull);
    });

    test('rejects a different Google account', () async {
      final user = RecordingUser(
        reauthenticateError: FirebaseAuthException(code: 'user-mismatch'),
      );
      stubGooglePicker();

      expect(
        signedInAs(user).reauthenticate(),
        ErrorWithMessage<FirebaseSignInError>(
          KaziLocalizations.current.errorReauthenticationWrongAccount,
        ),
      );
    });

    test('returns false when nobody is signed in', () async {
      expect(await authService.reauthenticate(), isFalse);
      verifyNever(googleSignIn.authenticate());
    });

    test('asks an Apple account to sign in with Apple', () async {
      final user = RecordingUser(providerIds: ['apple.com']);

      final confirmed = await signedInAs(user).reauthenticate();

      expect(confirmed, isTrue);
      expect(user.reauthenticatedWithProvider, isA<AppleAuthProvider>());
      verifyNever(googleSignIn.authenticate());
    });

    test('returns false when the Apple sheet is dismissed', () async {
      final user = RecordingUser(
        providerIds: ['apple.com'],
        reauthenticateError: FirebaseAuthException(code: 'canceled'),
      );

      expect(await signedInAs(user).reauthenticate(), isFalse);
    });
  });

  group('Delete account', () {
    test('deletes the user and revokes the Google grant', () async {
      final user = RecordingUser();
      when(googleSignIn.disconnect()).thenAnswer((_) async {});
      final service = signedInAs(user);

      await service.deleteAccount();

      expect(user.deleted, isTrue);
      expect(service.user, isNull);
      verify(googleSignIn.disconnect()).called(1);
    });

    test('still succeeds when revoking the Google grant fails', () async {
      final user = RecordingUser();
      when(googleSignIn.disconnect()).thenThrow(Exception('offline'));

      await signedInAs(user).deleteAccount();

      expect(user.deleted, isTrue);
    });

    test('revokes the Apple grant before deleting the user', () async {
      final calls = <String>[];
      final user = RecordingUser(providerIds: ['apple.com'], calls: calls);
      final service = signedInAs(user, calls: calls);

      await service.reauthenticate();
      await service.deleteAccount();

      expect(calls, ['revoke:apple-code', 'delete']);
      verifyNever(googleSignIn.disconnect());
    });

    test('still deletes an Apple account with no code to revoke', () async {
      final calls = <String>[];
      final user = RecordingUser(
        providerIds: ['apple.com'],
        appleAuthorizationCode: null,
        calls: calls,
      );
      final service = signedInAs(user, calls: calls);

      await service.reauthenticate();
      await service.deleteAccount();

      expect(calls, ['delete']);
    });

    test('keeps the Google grant when the deletion is refused', () async {
      final user = RecordingUser(
        deleteError: FirebaseAuthException(code: 'requires-recent-login'),
      );

      await expectLater(
        signedInAs(user).deleteAccount(),
        throwsA(isA<FirebaseSignInError>()),
      );
      verifyNever(googleSignIn.disconnect());
    });
  });

  group('Listen user changes', () {
    test('Should return null when user is not signed in', () async {
      final result = authService.userChanges();

      result.listen((event) {
        expect(event, isNull);
      });
    });

    test('Should return user', () {
      firebaseAuth = MockFirebaseAuth(isSignedIn: true);
      authService = FirebaseAuthService(
        googleSignIn: googleSignIn,
        firebaseAuth: firebaseAuth,
        user: userMock,
        crashlyticsService: crashlyticsService,
      );
      final result = authService.userChanges();

      result.listen((event) {
        expect(event, isNotNull);
        expect(event!.uid, _user.uid);
      });
    });
  });
}
