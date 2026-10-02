import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kazi/features/auth/presenter/controllers/delete_account_controller.dart';
import 'package:kazi/injector.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// Confirms the deletion; the progress and any failure are shown by the
/// `AccountActionProgress` wrapping the screen that opened it.
Future<void> showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
  final message = [
    KaziLocalizations.current.deleteAccountConfirmation,
    // The store keeps billing a deleted account, and App Review requires
    // saying so before the deletion rather than after.
    if (ref.read(isPremiumProvider))
      KaziLocalizations.current.deleteAccountSubscriptionNote(_storeName),
  ].join('\n\n');

  return KaziNavigator.showDialog(
    context: context,
    builder: (_) => KaziDialog(
      onConfirm: () {
        context.pop();
        unawaited(
          ref.read(deleteAccountControllerProvider.notifier).deleteAccount(),
        );
      },
      onCancel: context.pop,
      title: KaziLocalizations.current.deleteAccountTitle,
      message: message,
      confirmText: KaziLocalizations.current.deleteAccountConfirm,
      cancelText: KaziLocalizations.current.cancel,
      isDestructive: true,
    ),
  );
}

String get _storeName =>
    defaultTargetPlatform == TargetPlatform.iOS ? 'App Store' : 'Google Play';
