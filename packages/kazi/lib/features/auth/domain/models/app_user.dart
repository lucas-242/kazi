class AppUser {
  AppUser({
    required this.name,
    required this.email,
    this.photoUrl,
    required this.uid,
    this.createdAt,
  });
  final String name;
  final String email;
  final String? photoUrl;
  final String uid;

  /// When the account was created, from Firebase Auth's own metadata.
  ///
  /// Null when the provider did not report it. Analytics uses it for the
  /// account-age cohort and for the session-replay sampling split — both of
  /// which need the age of the *account*, not of the install, so a returning
  /// user on a new phone is not mistaken for a newcomer.
  final DateTime? createdAt;

  String get shortName => name.length > 18 ? name.split('').first : name;

  bool get thereIsPhoto => photoUrl != null && photoUrl!.isNotEmpty;
}
