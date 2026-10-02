import 'package:kazi/features/onboarding/presenter/controllers/active_user_nudges_controller.dart';
import 'package:kazi/features/onboarding/presenter/controllers/checklist_controller.dart';
import 'package:kazi/features/onboarding/presenter/controllers/guided_setup_controller.dart';
import 'package:kazi/features/onboarding/presenter/controllers/onboarding_controller.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// Kept alive and resolved for whoever was signed in, so they must be
/// invalidated when that account leaves. Without it, the next person to sign
/// in on this device inherits their segment — and could be sent through a
/// setup that is not theirs, or skip one that is.
final List<ProviderOrFamily> accountScopedProviders = [
  onboardingControllerProvider,
  guidedSetupControllerProvider,
  checklistControllerProvider,
  activeUserNudgesControllerProvider,
  kaziCurrencyControllerProvider,
];
