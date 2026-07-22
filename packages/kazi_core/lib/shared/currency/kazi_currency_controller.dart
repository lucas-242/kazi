import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:kazi_core/kazi_providers.dart';
import 'package:kazi_core/shared/currency/kazi_currency_manager.dart';
import 'package:kazi_core/shared/currency/supported_currency.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'kazi_currency_controller.g.dart';

@riverpod
Future<KaziCurrencyManager> kaziCurrencyManager(Ref ref) async {
  final storage = await ref.watch(localStorageProvider.future);
  return KaziCurrencyManager(storage: storage);
}

@riverpod
class KaziCurrencyController extends _$KaziCurrencyController {
  Future<KaziCurrencyManager> get _managerFuture =>
      ref.read(kaziCurrencyManagerProvider.future);

  @override
  FutureOr<SupportedCurrency> build() async {
    final manager = await ref.watch(kaziCurrencyManagerProvider.future);
    final countryCode =
        WidgetsBinding.instance.platformDispatcher.locale.countryCode ?? '';
    return manager.loadDefaultCurrency(deviceCountryCode: countryCode);
  }

  Future<void> selectCurrency(SupportedCurrency currency) async {
    final manager = await _managerFuture;
    final selected = await manager.selectCurrency(currency);
    state = AsyncData(selected);
  }
}

/// Effective default currency, falling back to USD while loading.
@riverpod
SupportedCurrency kaziDefaultCurrency(Ref ref) =>
    ref.watch(kaziCurrencyControllerProvider).asData?.value ??
    SupportedCurrency.usd;
