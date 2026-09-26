import 'package:kazi/core/utils/base_state.dart';
import 'package:kazi/features/onboarding/domain/models/profession_preset.dart';
import 'package:kazi/features/onboarding/domain/models/setup_catalog_item.dart';
import 'package:kazi/features/onboarding/domain/preset_catalog.dart';
import 'package:kazi/features/settings/domain/models/billing_cycle.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// The screens of the guided setup, in order. One question per screen — two
/// together double the odds of stalling.
enum SetupStep {
  profession,
  currency,
  cycle,
  catalog,
  commission,
  firstService,

  /// Not a question: the first real number, which is the whole point of the
  /// questions that came before it.
  result,
}

/// Which questions an account is asked. See `features/onboarding/README.md`.
enum SetupFlow {
  /// No service registered yet: the profession picks a kit, which seeds the
  /// catalog, and the setup ends on a first service.
  ///
  /// The currency comes before the catalog: every price typed there is stored
  /// in it.
  full([
    SetupStep.profession,
    SetupStep.currency,
    SetupStep.cycle,
    SetupStep.catalog,
    SetupStep.commission,
    SetupStep.firstService,
  ]),

  /// Services already exist: only what the account predates. No kit is ever
  /// offered — the catalog is already theirs.
  essentials([SetupStep.profession, SetupStep.currency, SetupStep.cycle]);

  const SetupFlow(this.steps);

  /// The question screens, in order. The result is an outcome, not a step.
  final List<SetupStep> steps;

  SetupStep? after(SetupStep step) {
    final index = steps.indexOf(step);
    return index < 0 || index + 1 >= steps.length ? null : steps[index + 1];
  }

  SetupStep? before(SetupStep step) {
    final index = steps.indexOf(step);
    return index <= 0 ? null : steps[index - 1];
  }
}

class GuidedSetupState extends BaseState {
  GuidedSetupState({
    required super.status,
    super.callbackMessage,
    required this.userId,
    required this.currency,
    this.flow = SetupFlow.full,
    this.hasExistingServices = false,
    this.isPreview = false,
    this.step = SetupStep.profession,
    this.preset,
    this.customProfession = '',
    this.isSelfEmployed = true,
    this.commissionAnswered = false,
    this.items = const [],
    this.billingCycle = BillingCycle.monthlyDefault,
    this.firstServiceItemId,
    this.firstServiceDate,
    this.registeredValue,
    this.registeredCommission,
  });

  final String userId;

  /// The currency everything is seeded in. Resolved once, by awaiting the
  /// currency controller rather than reading the synchronous default — that
  /// one answers USD while it is still loading, which would stamp USD onto
  /// every user who set up fast enough.
  final SupportedCurrency currency;

  final SetupFlow flow;

  /// Whether services were registered before the setup — they take the
  /// currency confirmed on the currency screen.
  final bool hasExistingServices;

  /// A debug rehearsal that writes nothing. See README.md.
  final bool isPreview;

  final SetupStep step;

  /// Null while the user is on the first screen, or when they typed a
  /// profession no kit matched.
  final ProfessionPreset? preset;

  /// What the user typed when no kit matched. Kept as research.
  final String customProfession;

  /// Only meaningful on the typed-profession path, where the question is asked
  /// as "do you work for yourself?" rather than as a percentage.
  final bool isSelfEmployed;

  /// Whether the user has said what they keep. Until then the kit's default
  /// commission is a guess, and no screen shows it as if it were their answer.
  final bool commissionAnswered;

  final List<SetupCatalogItem> items;
  final BillingCycle billingCycle;

  final String? firstServiceItemId;
  final DateTime? firstServiceDate;

  /// The gross value and the take-home of the service just registered — what
  /// the closing screen reports back. Null when the user chose to skip it.
  final double? registeredValue;
  final double? registeredCommission;

  List<SetupCatalogItem> get selectedItems =>
      items.where((item) => item.selected).toList();

  /// The profession key to persist: the kit's, or the "other" marker.
  String get professionKey => preset?.key ?? PresetCatalog.otherKey;

  bool get hasRegisteredService => registeredValue != null;

  /// Whether the setup can move on from the catalog screen. One service is
  /// enough for the app to calculate — asking for three before delivering
  /// anything strands people at the door.
  bool get canContinueFromCatalog => selectedItems.isNotEmpty;

  /// Whether [item]'s commission is something the user said, rather than the
  /// kit's guess.
  bool isCommissionKnown(SetupCatalogItem item) =>
      commissionAnswered || item.hasCustomCommission;

  bool get canContinueFromCommission =>
      selectedItems.isNotEmpty && selectedItems.every(isCommissionKnown);

  @override
  GuidedSetupState copyWith({
    BaseStateStatus? status,
    String? callbackMessage,
    SupportedCurrency? currency,
    SetupStep? step,
    ProfessionPreset? Function()? preset,
    String? customProfession,
    bool? isSelfEmployed,
    bool? commissionAnswered,
    List<SetupCatalogItem>? items,
    BillingCycle? billingCycle,
    String? Function()? firstServiceItemId,
    DateTime? Function()? firstServiceDate,
    double? registeredValue,
    double? registeredCommission,
  }) => GuidedSetupState(
    status: status ?? this.status,
    callbackMessage: callbackMessage ?? this.callbackMessage,
    userId: userId,
    currency: currency ?? this.currency,
    flow: flow,
    hasExistingServices: hasExistingServices,
    isPreview: isPreview,
    step: step ?? this.step,
    preset: preset == null ? this.preset : preset(),
    customProfession: customProfession ?? this.customProfession,
    isSelfEmployed: isSelfEmployed ?? this.isSelfEmployed,
    commissionAnswered: commissionAnswered ?? this.commissionAnswered,
    items: items ?? this.items,
    billingCycle: billingCycle ?? this.billingCycle,
    firstServiceItemId: firstServiceItemId == null
        ? this.firstServiceItemId
        : firstServiceItemId(),
    firstServiceDate: firstServiceDate == null
        ? this.firstServiceDate
        : firstServiceDate(),
    registeredValue: registeredValue ?? this.registeredValue,
    registeredCommission: registeredCommission ?? this.registeredCommission,
  );
}
