import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_providers.dart';
import 'package:kazi_core/shared/services/local_storage/kazi_local_storage_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'kazi_theme_controller.g.dart';

/// The user's theme choice, persisted on the device.
///
/// Device-scoped rather than account-scoped on purpose: theme is a property of
/// the phone the person is holding, so it survives signing out — unlike the
/// currency, which belongs to the work and travels with the account.
@riverpod
class KaziThemeController extends _$KaziThemeController {
  static const String _key = 'userThemeMode';

  Future<KaziLocalStorageService> get _storage =>
      ref.read(localStorageProvider.future);

  @override
  FutureOr<ThemeMode> build() async {
    final storage = await ref.watch(localStorageProvider.future);
    final stored = await storage.read<String>(_key);

    return ThemeMode.values.firstWhere(
      (mode) => mode.name == stored,
      // Covers a missing key and a value written by an older build that no
      // longer maps to anything.
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> selectThemeMode(ThemeMode mode) async {
    final storage = await _storage;
    await storage.write<String>(_key, mode.name);
    state = AsyncData(mode);
  }
}
