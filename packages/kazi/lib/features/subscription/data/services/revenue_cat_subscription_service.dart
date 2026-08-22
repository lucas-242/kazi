import 'dart:async';

import 'package:flutter/services.dart' show PlatformException;
import 'package:kazi/features/subscription/data/errors/subscription_errors.dart';
import 'package:kazi/features/subscription/domain/models/entitlement.dart';
import 'package:kazi/features/subscription/domain/services/subscription_service.dart';
import 'package:kazi/features/subscription/domain/subscription_constants.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;
import 'package:purchases_flutter/purchases_flutter.dart';

/// RevenueCat-backed [SubscriptionService]. Maps RevenueCat's [CustomerInfo]
/// into the app's [Entitlement]; grace period, trial eligibility and the
/// "trial once per user" rule are enforced by RevenueCat/the store.
final class RevenueCatSubscriptionService implements SubscriptionService {
  RevenueCatSubscriptionService(this._apiKey);

  final String _apiKey;

  final StreamController<Entitlement> _controller =
      StreamController<Entitlement>.broadcast();
  Entitlement _last = const Entitlement.free();
  bool _configured = false;

  @override
  Future<void> configure(String? appUserId) async {
    if (_configured) {
      return;
    }
    final configuration = PurchasesConfiguration(_apiKey)
      ..appUserID = appUserId;
    await Purchases.configure(configuration);
    Purchases.addCustomerInfoUpdateListener(_onCustomerInfo);
    _configured = true;
    try {
      _onCustomerInfo(await Purchases.getCustomerInfo());
    } catch (exception) {
      // Startup entitlement fetch is best-effort; the listener will catch up.
      Log.error('Failed to fetch initial entitlement: $exception');
    }
  }

  @override
  Future<void> logIn(String appUserId) async {
    final result = await Purchases.logIn(appUserId);
    _onCustomerInfo(result.customerInfo);
  }

  @override
  Future<void> logOut() async {
    if (!_configured) {
      return;
    }

    try {
      if (await Purchases.isAnonymous) {
        return;
      }
      _onCustomerInfo(await Purchases.logOut());
    } on PlatformException catch (exception) {
      Log.error('Failed to log out of RevenueCat: ${exception.message}');
    }
  }

  @override
  Future<Entitlement> current() async {
    final info = await Purchases.getCustomerInfo();
    return _map(info);
  }

  @override
  Stream<Entitlement> changes() async* {
    yield _last;
    yield* _controller.stream;
  }

  @override
  Future<bool> isTrialEligible() async {
    try {
      final result = await Purchases.checkTrialOrIntroductoryPriceEligibility([
        SubscriptionConstants.monthlyProductId,
      ]);
      final status = result[SubscriptionConstants.monthlyProductId]?.status;
      return status == IntroEligibilityStatus.introEligibilityStatusEligible;
    } catch (exception) {
      Log.error('Failed to check trial eligibility: $exception');
      return false;
    }
  }

  @override
  Future<String?> monthlyPriceString() async {
    try {
      final package = await _monthlyPackage();
      return package.storeProduct.priceString;
    } catch (exception) {
      Log.error('Failed to load monthly price: $exception');
      return null;
    }
  }

  @override
  Future<Entitlement> purchaseMonthly() async {
    final package = await _monthlyPackage();
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      _onCustomerInfo(result.customerInfo);
      return _map(result.customerInfo);
    } on PlatformException catch (exception, trace) {
      final code = PurchasesErrorHelper.getErrorCode(exception);
      if (code == PurchasesErrorCode.purchaseCancelledError) {
        throw PurchaseCancelledError('Purchase cancelled', trace: trace);
      }
      throw ExternalError(exception.message ?? 'Purchase failed', trace: trace);
    }
  }

  @override
  Future<Entitlement> restore() async {
    try {
      final info = await Purchases.restorePurchases();
      _onCustomerInfo(info);
      return _map(info);
    } on PlatformException catch (exception, trace) {
      throw ExternalError(exception.message ?? 'Restore failed', trace: trace);
    }
  }

  Future<Package> _monthlyPackage() async {
    try {
      final offerings = await Purchases.getOfferings();
      final offering =
          offerings.current ??
          offerings.all[SubscriptionConstants.monthlyOffering];
      final package =
          offering?.monthly ?? offering?.availablePackages.firstOrNull;
      if (package == null) {
        throw OfferingUnavailableError('No subscription package available');
      }
      return package;
    } on PlatformException catch (exception, trace) {
      throw OfferingUnavailableError(
        exception.message ?? 'Failed to load offerings',
        trace: trace,
      );
    }
  }

  void _onCustomerInfo(CustomerInfo info) {
    _last = _map(info);
    if (!_controller.isClosed) {
      _controller.add(_last);
    }
  }

  Entitlement _map(CustomerInfo info) {
    final entitlement =
        info.entitlements.all[SubscriptionConstants.premiumEntitlement];
    if (entitlement == null) {
      return const Entitlement.free();
    }

    final isActive = entitlement.isActive;
    final isTrial = entitlement.periodType == PeriodType.trial;
    // A "normal" period means the user has been charged at least once.
    final hasPaidBefore = entitlement.periodType == PeriodType.normal;
    final isInGracePeriod =
        isActive && entitlement.billingIssueDetectedAt != null;

    return Entitlement(
      isPremium: isActive,
      isInGracePeriod: isInGracePeriod,
      willRenew: entitlement.willRenew,
      isTrial: isActive && isTrial,
      hasPaidBefore: hasPaidBefore,
      expirationDate: entitlement.expirationDate != null
          ? DateTime.tryParse(entitlement.expirationDate!)
          : null,
    );
  }
}
