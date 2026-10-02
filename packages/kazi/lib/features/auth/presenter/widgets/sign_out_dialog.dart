import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kazi/features/auth/presenter/controllers/sign_out_controller.dart';
import 'package:kazi_core/kazi_core.dart'
    hide Service, CatalogItem, CatalogItemRepository;

/// Confirms the sign-out; the progress and any failure are shown by the
/// `AccountActionProgress` wrapping the screen that opened it.
Future<void> showSignOutDialog(BuildContext context, WidgetRef ref) {
  return KaziNavigator.showDialog(
    context: context,
    builder: (_) => KaziDialog(
      onConfirm: () {
        context.pop();
        unawaited(ref.read(signOutControllerProvider.notifier).signOut());
      },
      onCancel: context.pop,
      title: KaziLocalizations.current.signOutTitle,
      message: KaziLocalizations.current.signOutConfirmation,
      confirmText: KaziLocalizations.current.signOutConfirm,
      cancelText: KaziLocalizations.current.cancel,
      isDestructive: true,
    ),
  );
}
