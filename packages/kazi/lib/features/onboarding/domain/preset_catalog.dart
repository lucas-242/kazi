import 'package:kazi/features/onboarding/domain/models/profession_preset.dart';
import 'package:kazi/features/onboarding/domain/models/service_preset.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// The nine starter kits offered by the guided setup.
///
/// Prices are informed guesses, not market research: they exist so someone
/// recognises the service and corrects the number, and every one of them is
/// editable on the screen where it appears. They are worth revalidating with
/// real professionals before each release and revisiting yearly — a stale
/// price reads as an abandoned app.
abstract final class PresetCatalog {
  static final List<ProfessionPreset> all = [
    _manicure,
    _hair,
    _esthetics,
    _makeup,
    _massage,
    _personalTrainer,
    _cleaning,
    _handyman,
    _design,
  ];

  /// The kits offered as chips on the first screen. The rest are reachable by
  /// typing, so the opening question stays a four-way choice instead of a list.
  static List<ProfessionPreset> get featured => [_manicure, _hair, _esthetics];

  /// The key stored when the user typed a profession no kit matches. Their text
  /// is stored alongside it: the most frequent answers are the queue of presets
  /// still to build.
  static const String otherKey = 'other';

  /// Commission for someone who works for a salon, when no kit applies.
  static const double employedCommissionPercent = 40;

  /// Commission for someone self-employed: they keep everything.
  static const double selfEmployedCommissionPercent = 100;

  static ProfessionPreset? byKey(String key) {
    for (final preset in all) {
      if (preset.key == key) return preset;
    }
    return null;
  }

  /// Kits whose name or synonyms match [query].
  ///
  /// Matching is on a normalized substring, so "unhas", "depilação" and
  /// "tattoo" all land somewhere, and an empty or unmatched query returns
  /// nothing rather than everything — the screen then invites the user to keep
  /// typing instead of showing a list they did not ask for.
  static List<ProfessionPreset> search(String query) {
    final normalized = normalize(query);
    if (normalized.isEmpty) return const [];

    return all.where((preset) {
      if (normalize(preset.label()).contains(normalized)) return true;
      return preset.synonyms.any((synonym) => synonym.contains(normalized));
    }).toList();
  }

  static String normalize(String value) => value.normalizedName;

  static final _manicure = ProfessionPreset(
    key: 'manicure',
    label: () => KaziLocalizations.current.presetManicure,
    defaultCommissionPercent: 40,
    synonyms: ['manicure', 'pedicure', 'unha', 'unhas', 'nail', 'nails', 'gel'],
    services: [
      ServicePreset(
        label: () => KaziLocalizations.current.presetManicurePolishHands,
        brlPrice: 45,
        preSelected: true,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetManicurePolishFeet,
        brlPrice: 50,
        preSelected: true,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetManicureHandsAndFeet,
        brlPrice: 80,
        preSelected: true,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetManicureGelExtension,
        brlPrice: 180,
        preSelected: true,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetManicureGelRefill,
        brlPrice: 90,
        preSelected: true,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetManicureStrengthening,
        brlPrice: 155,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetManicureFootSpa,
        brlPrice: 120,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetManicureExtensionRemoval,
        brlPrice: 50,
      ),
    ],
  );

  static final _hair = ProfessionPreset(
    key: 'hair',
    label: () => KaziLocalizations.current.presetHair,
    defaultCommissionPercent: 40,
    synonyms: [
      'cabelo',
      'cabeleireiro',
      'barbeiro',
      'barbearia',
      'corte',
      'hair',
      'barber',
      'peluqueria',
      'pelo',
    ],
    services: [
      ServicePreset(
        label: () => KaziLocalizations.current.presetHairMensCut,
        brlPrice: 45,
        preSelected: true,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetHairWomensCut,
        brlPrice: 70,
        preSelected: true,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetHairBeard,
        brlPrice: 35,
        preSelected: true,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetHairCutAndBeard,
        brlPrice: 70,
        preSelected: true,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetHairBlowDry,
        brlPrice: 60,
        preSelected: true,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetHairColoring,
        brlPrice: 150,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetHairHighlights,
        brlPrice: 280,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetHairConditioning,
        brlPrice: 90,
      ),
    ],
  );

  static final _esthetics = ProfessionPreset(
    key: 'esthetics',
    label: () => KaziLocalizations.current.presetEsthetics,
    defaultCommissionPercent: 40,
    synonyms: [
      'estetica',
      'sobrancelha',
      'depilacao',
      'cilios',
      'pele',
      'henna',
      'brow',
      'lash',
      'wax',
      'esthetic',
      'cejas',
      'depilacion',
    ],
    services: [
      ServicePreset(
        label: () => KaziLocalizations.current.presetEstheticsBrowDesign,
        brlPrice: 45,
        preSelected: true,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetEstheticsBrowHenna,
        brlPrice: 60,
        preSelected: true,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetEstheticsFacialCleansing,
        brlPrice: 130,
        preSelected: true,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetEstheticsUpperLipWax,
        brlPrice: 25,
        preSelected: true,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetEstheticsUnderarmWax,
        brlPrice: 35,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetEstheticsFullLegWax,
        brlPrice: 80,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetEstheticsLashExtensions,
        brlPrice: 200,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetEstheticsPeeling,
        brlPrice: 180,
      ),
    ],
  );

  static final _makeup = ProfessionPreset(
    key: 'makeup',
    label: () => KaziLocalizations.current.presetMakeup,
    defaultCommissionPercent: 100,
    synonyms: ['maquiagem', 'maquiador', 'makeup', 'maquillaje', 'noiva'],
    services: [
      ServicePreset(
        label: () => KaziLocalizations.current.presetMakeupSocial,
        brlPrice: 150,
        preSelected: true,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetMakeupBridesmaid,
        brlPrice: 250,
        preSelected: true,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetMakeupGraduation,
        brlPrice: 200,
        preSelected: true,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetMakeupBride,
        brlPrice: 600,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetMakeupClass,
        brlPrice: 300,
      ),
    ],
  );

  static final _massage = ProfessionPreset(
    key: 'massage',
    label: () => KaziLocalizations.current.presetMassage,
    defaultCommissionPercent: 50,
    synonyms: [
      'massagem',
      'massoterapia',
      'drenagem',
      'spa',
      'massage',
      'masaje',
      'bem estar',
    ],
    services: [
      ServicePreset(
        label: () => KaziLocalizations.current.presetMassageRelaxing,
        brlPrice: 130,
        preSelected: true,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetMassageLymphatic,
        brlPrice: 150,
        preSelected: true,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetMassageContouring,
        brlPrice: 160,
        preSelected: true,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetMassageHotStone,
        brlPrice: 180,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetMassagePackTen,
        brlPrice: 1200,
      ),
    ],
  );

  static final _personalTrainer = ProfessionPreset(
    key: 'personal_trainer',
    label: () => KaziLocalizations.current.presetPersonalTrainer,
    defaultCommissionPercent: 100,
    synonyms: [
      'personal',
      'treinador',
      'educacao fisica',
      'academia',
      'trainer',
      'fitness',
      'entrenador',
      'pilates',
      'yoga',
    ],
    services: [
      ServicePreset(
        label: () => KaziLocalizations.current.presetPersonalSingleSession,
        brlPrice: 90,
        preSelected: true,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetPersonalPackEight,
        brlPrice: 600,
        preSelected: true,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetPersonalMonthlyPlan,
        brlPrice: 700,
        preSelected: true,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetPersonalAssessment,
        brlPrice: 120,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetPersonalOnlineProgram,
        brlPrice: 200,
      ),
    ],
  );

  static final _cleaning = ProfessionPreset(
    key: 'cleaning',
    label: () => KaziLocalizations.current.presetCleaning,
    defaultCommissionPercent: 100,
    synonyms: [
      'limpeza',
      'faxina',
      'diarista',
      'domestica',
      'cleaning',
      'housekeeping',
      'limpieza',
    ],
    services: [
      ServicePreset(
        label: () => KaziLocalizations.current.presetCleaningFullDay,
        brlPrice: 180,
        preSelected: true,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetCleaningHalfDay,
        brlPrice: 110,
        preSelected: true,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetCleaningDeepClean,
        brlPrice: 250,
        preSelected: true,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetCleaningIroning,
        brlPrice: 40,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetCleaningPostConstruction,
        brlPrice: 350,
      ),
    ],
  );

  static final _handyman = ProfessionPreset(
    key: 'handyman',
    label: () => KaziLocalizations.current.presetHandyman,
    defaultCommissionPercent: 100,
    synonyms: [
      'montagem',
      'montador',
      'reparo',
      'conserto',
      'marceneiro',
      'eletricista',
      'encanador',
      'handyman',
      'repair',
      'reparacion',
    ],
    services: [
      ServicePreset(
        label: () => KaziLocalizations.current.presetHandymanWardrobe,
        brlPrice: 180,
        preSelected: true,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetHandymanBed,
        brlPrice: 120,
        preSelected: true,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetHandymanTvMount,
        brlPrice: 150,
        preSelected: true,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetHandymanShelf,
        brlPrice: 80,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetHandymanCallout,
        brlPrice: 100,
      ),
    ],
  );

  static final _design = ProfessionPreset(
    key: 'design',
    label: () => KaziLocalizations.current.presetDesign,
    defaultCommissionPercent: 100,
    synonyms: [
      'design',
      'designer',
      'criacao',
      'social media',
      'freela',
      'freelancer',
      'logo',
      'marketing',
      'diseno',
    ],
    services: [
      ServicePreset(
        label: () => KaziLocalizations.current.presetDesignLogo,
        brlPrice: 1200,
        preSelected: true,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetDesignSocialPost,
        brlPrice: 120,
        preSelected: true,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetDesignHourly,
        brlPrice: 150,
        preSelected: true,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetDesignBrandIdentity,
        brlPrice: 3500,
      ),
      ServicePreset(
        label: () => KaziLocalizations.current.presetDesignLandingPage,
        brlPrice: 2500,
      ),
    ],
  );
}
