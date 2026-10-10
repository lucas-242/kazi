abstract class AccountDataRepository {
  /// Deletes every document the account owns. Safe to run again after a
  /// failure: whatever was already deleted is simply not found.
  Future<void> deleteAll(String userId);
}
