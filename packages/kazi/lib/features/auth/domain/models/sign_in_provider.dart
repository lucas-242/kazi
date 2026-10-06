enum SignInProvider {
  google('google.com'),
  apple('apple.com');

  const SignInProvider(this.providerId);

  /// Firebase Auth's id for the provider, as found in `User.providerData`.
  final String providerId;
}
