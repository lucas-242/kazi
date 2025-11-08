import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart';

part 'snackbar_overlay.dart';

class KaziSnackbar {
  factory KaziSnackbar() {
    return _singleton;
  }

  KaziSnackbar._internal();

  static final KaziSnackbar _singleton = KaziSnackbar._internal();

  static OverlayState? overlayState;
  static OverlayEntry? _overlayEntry;
  static bool _isVisible = false;

  static Future<void> _createView(
    BuildContext context,
    String message,
    int duration, {
    bool? rootNavigator,
  }) async {
    overlayState = Overlay.of(context, rootOverlay: rootNavigator ?? false);
    _overlayEntry = _getSnackbarOverlay(message);

    _isVisible = true;
    overlayState!.insert(_overlayEntry!);
    await Future.delayed(Duration(seconds: duration));
    _dismiss();
  }

  static Future<void> _dismiss() async {
    if (!_isVisible) {
      return;
    }
    _isVisible = false;
    _overlayEntry?.remove();
  }

  static void show(
    BuildContext context,
    String message, {
    int duration = 4,
    bool rootNavigator = false,
  }) {
    _dismiss();
    _createView(context, message, duration, rootNavigator: rootNavigator);
  }
}
