import 'package:flutter/material.dart';
import 'package:kazi_core/shared/l10n/generated/l10n.dart';

/// The band that says what just happened and offers the move back.
///
/// Five seconds, which is the window the design gives every reversible
/// destructive action — archiving, marking a batch received. Anything without a
/// way back gets a dialog instead, and nothing gets both.
///
/// `KaziSnackbar` carries no action, which is why this reaches for Material's
/// own rather than extending it: an undo is a snackbar with a button, and a
/// snackbar without one is a different component with different rules.
abstract final class KaziUndoSnackbar {
  static const Duration _window = Duration(seconds: 5);

  /// [message] states what happened in the same words the action used — "the
  /// label is a contract". [onUndo] must act on the exact records that were
  /// written, never on a list re-derived afterwards.
  static void show(
    BuildContext context, {
    required String message,
    required VoidCallback onUndo,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: _window,
        persist: false,
        content: Text(message),
        action: SnackBarAction(
          label: KaziLocalizations.current.undo,
          onPressed: onUndo,
        ),
      ),
    );
  }
}
