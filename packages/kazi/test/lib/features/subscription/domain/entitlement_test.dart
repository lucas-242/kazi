import 'package:flutter_test/flutter_test.dart';
import 'package:kazi/features/subscription/domain/models/entitlement.dart';
import 'package:kazi/features/subscription/domain/models/user_tier.dart';

void main() {
  group('Entitlement.tier', () {
    test('premium when active, regardless of paid history', () {
      const active = Entitlement(
        isPremium: true,
        isInGracePeriod: false,
        willRenew: true,
        isTrial: false,
        hasPaidBefore: false,
      );
      expect(active.tier, UserTier.premium);
    });

    test('active trial is premium', () {
      const trial = Entitlement(
        isPremium: true,
        isInGracePeriod: false,
        willRenew: false,
        isTrial: true,
        hasPaidBefore: false,
      );
      expect(trial.tier, UserTier.premium);
    });

    test('churned when inactive but has paid before', () {
      const churned = Entitlement(
        isPremium: false,
        isInGracePeriod: false,
        willRenew: false,
        isTrial: false,
        hasPaidBefore: true,
      );
      expect(churned.tier, UserTier.churned);
    });

    test('newFree when inactive and never paid (trial-only cancel)', () {
      const free = Entitlement.free();
      expect(free.tier, UserTier.newFree);
    });
  });
}
