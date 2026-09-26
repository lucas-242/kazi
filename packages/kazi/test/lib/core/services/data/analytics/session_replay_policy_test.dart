import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/core/services/data/analytics/session_replay_policy.dart';

/// The sampling is the only thing standing between the replay quota and every
/// session every user ever has, and the kill switch is the only way to stop it
/// without shipping a release. Both are worth being able to prove.
void main() {
  SessionReplayPolicy policy({
    bool isEnabled = true,
    bool recordsOnFriction = true,
    int newUserPercent = 100,
    int returningPercent = 20,
    int newUserDays = 7,
  }) => SessionReplayPolicy.raw(
    isEnabled: isEnabled,
    recordsOnFriction: recordsOnFriction,
    newUserSamplePercent: newUserPercent,
    returningSamplePercent: returningPercent,
    newUserDays: newUserDays,
  );

  group('kill switch', () {
    test('records nothing at session start when disabled', () {
      final disabled = policy(isEnabled: false);

      expect(
        disabled.shouldRecordAtStart(isNewUser: true, roll: 0),
        isFalse,
        reason: 'the switch has to beat the 100% new-user band',
      );
    });

    test('records nothing on friction when disabled', () {
      expect(policy(isEnabled: false).shouldRecordOnFriction(), isFalse);
    });
  });

  group('sampling bands', () {
    test('records every new user at the default 100%', () {
      final subject = policy();

      // The whole range, since the roll is the only thing that varies.
      for (final roll in [0.0, 0.5, 0.99]) {
        expect(
          subject.shouldRecordAtStart(isNewUser: true, roll: roll),
          isTrue,
        );
      }
    });

    test('records nobody at 0%', () {
      final subject = policy(newUserPercent: 0, returningPercent: 0);

      expect(subject.shouldRecordAtStart(isNewUser: true, roll: 0), isFalse);
      expect(subject.shouldRecordAtStart(isNewUser: false, roll: 0), isFalse);
    });

    test('splits returning users at the configured percentage', () {
      final subject = policy();

      expect(subject.shouldRecordAtStart(isNewUser: false, roll: 0.19), isTrue);
      expect(subject.shouldRecordAtStart(isNewUser: false, roll: 0.2), isFalse);
      expect(
        subject.shouldRecordAtStart(isNewUser: false, roll: 0.99),
        isFalse,
      );
    });

    test('uses the new-user band for new users, not the returning one', () {
      final subject = policy(returningPercent: 0);

      expect(subject.shouldRecordAtStart(isNewUser: true, roll: 0.9), isTrue);
      expect(subject.shouldRecordAtStart(isNewUser: false, roll: 0.0), isFalse);
    });
  });

  group('who counts as new', () {
    test('an account younger than the window is new', () {
      expect(policy().isNewUser(6), isTrue);
    });

    test('an account exactly at the window is not', () {
      expect(policy().isNewUser(7), isFalse);
    });

    test('an unknown age counts as new', () {
      // Over-recording a handful of sessions is the cheaper mistake: the whole
      // point of the new-user band is not to miss a first week.
      expect(policy().isNewUser(null), isTrue);
    });
  });
}
