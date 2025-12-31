import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:kazi_core/kazi_providers.dart';
import 'package:kazi_core/shared/l10n/generated/l10n.dart';
import 'package:kazi_core/shared/localization/kazi_locale_manager.dart';
import 'package:kazi_core/shared/localization/kazi_locale_policy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'kazi_locale_controller.g.dart';

@riverpod
class KaziLocaleController extends _$KaziLocaleController {
  Future<KaziLocaleManager> get _managerFuture =>
      ref.read(kaziLocaleManagerProvider.future);

  @override
  FutureOr<Locale?> build() async {
    final manager = await ref.watch(kaziLocaleManagerProvider.future);
    return manager.loadOverrideLocale();
  }

  Future<void> selectLanguage({
    required String languageCode,
  }) async {
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    final manager = await _managerFuture;
    final selected = await manager.selectLanguage(
      languageCode: languageCode,
      deviceLocale: deviceLocale,
    );
    state = AsyncData(selected);
  }
}

@riverpod
KaziLocalePolicy kaziLocalePolicy(Ref ref) => KaziLocalePolicy(
      supportedLocales: KaziLocalizations.delegate.supportedLocales,
    );

@riverpod
Future<KaziLocaleManager> kaziLocaleManager(Ref ref) async {
  final storage = await ref.watch(localStorageProvider.future);
  final policy = ref.watch(kaziLocalePolicyProvider);
  return KaziLocaleManager(storage: storage, policy: policy);
}

typedef KaziLocaleResolutionCallback = Locale Function(
  Locale?,
  Iterable<Locale>,
);

@riverpod
KaziLocaleResolutionCallback kaziLocaleResolutionCallback(Ref ref) {
  final effectiveLocale = ref.watch(kaziEffectiveLocaleProvider);

  return (locale, supportedLocales) {
    for (final supported in supportedLocales) {
      if (supported.languageCode == effectiveLocale.languageCode) {
        return supported;
      }
    }

    // if MaterialApp provides a locale that is unsupported, fallback to en.
    return const Locale('en');
  };
}

@riverpod
Locale kaziEffectiveLocale(Ref ref) {
  final overrideLocale = ref.watch(kaziLocaleControllerProvider).asData?.value;
  final policy = ref.watch(kaziLocalePolicyProvider);
  final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
  return policy.resolveDeviceLocale(overrideLocale ?? deviceLocale);
}
