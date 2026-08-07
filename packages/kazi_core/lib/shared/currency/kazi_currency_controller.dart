import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:kazi_core/kazi_providers.dart';
import 'package:kazi_core/shared/currency/kazi_currency_manager.dart';
import 'package:kazi_core/shared/currency/kazi_remote_currency_store.dart';
import 'package:kazi_core/shared/currency/supported_currency.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'kazi_currency_controller.g.dart';

@riverpod
Future<KaziCurrencyManager> kaziCurrencyManager(Ref ref) async {
  final storage = await ref.watch(localStorageProvider.future);
  return KaziCurrencyManager(storage: storage);
}

/// Cross-device home for the default currency. Null keeps the local-only
/// behaviour; kazi overrides it with the user-document store.
@Riverpod(keepAlive: true)
KaziRemoteCurrencyStore? kaziRemoteCurrencyStore(Ref ref) => null;

@Riverpod(keepAlive: true)
class KaziCurrencyController extends _$KaziCurrencyController {
  Future<KaziCurrencyManager> get _managerFuture =>
      ref.read(kaziCurrencyManagerProvider.future);

  /// Resolution order: the user's stored choice (remote, authoritative) ->
  /// the local cache -> a guess from the device country.
  @override
  FutureOr<SupportedCurrency> build() async {
    final manager = await ref.watch(kaziCurrencyManagerProvider.future);
    final remote = await _readRemote();

    if (remote != null) {
      // Refresh the cache so the next cold start renders the right currency on
      // the first frame instead of waiting for the network.
      await manager.selectCurrency(remote);
      return remote;
    }

    final countryCode =
        WidgetsBinding.instance.platformDispatcher.locale.countryCode ?? '';
    return manager.loadDefaultCurrency(deviceCountryCode: countryCode);
  }

  Future<void> selectCurrency(SupportedCurrency currency) async {
    final manager = await _managerFuture;
    final selected = await manager.selectCurrency(currency);
    await ref.read(kaziRemoteCurrencyStoreProvider)?.write(selected);
    state = AsyncData(selected);
  }

  Future<SupportedCurrency?> _readRemote() async {
    final store = ref.watch(kaziRemoteCurrencyStoreProvider);
    if (store == null) return null;

    try {
      return await store.read();
    } catch (_) {
      // Offline or signed out: the local cache answers instead.
      return null;
    }
  }
}

/// Effective default currency, falling back to USD while loading.
@riverpod
SupportedCurrency kaziDefaultCurrency(Ref ref) =>
    ref.watch(kaziCurrencyControllerProvider).asData?.value ??
    SupportedCurrency.usd;
