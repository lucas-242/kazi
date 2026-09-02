import 'package:flutter/material.dart';
import 'package:kazi_core/shared/components/buttons/kazi_circular_button.dart';
import 'package:kazi_core/shared/navigation/kazi_navigator.dart';

/// The icon button that dismisses a screen instead of stepping back from it.
///
/// A form reached from the register button is not a place in the history the
/// user walked into — it is a sheet that grew into a screen. The chevron
/// promises the screen behind it; the cross says what actually happens, which
/// is that the form is dropped.
class KaziCloseButton extends StatelessWidget {
  const KaziCloseButton({super.key, this.onTap});

  /// Defaults to [KaziNavigator.pop].
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return KaziCircularButton.plain(
      onTap: onTap ?? KaziNavigator.pop,
      child: const Icon(Icons.close),
    );
  }
}
