import 'package:flutter/material.dart';
import 'package:kazi_core/shared/components/buttons/kazi_circular_button.dart';
import 'package:kazi_core/shared/navigation/kazi_navigator.dart';

/// The icon button that leaves a screen.
///
/// Backgroundless and sized like every other icon button in a bar: a filled
/// circle leading the title reads as the screen's primary action, which it
/// never is, and the ring of padding a wider one needs pushes the chevron away
/// from the edge it should be sitting on.
class KaziBackButton extends StatelessWidget {
  const KaziBackButton({super.key, this.onTap});

  /// Defaults to [KaziNavigator.pop].
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return KaziCircularButton.plain(
      onTap: onTap ?? KaziNavigator.pop,
      child: const Icon(Icons.chevron_left),
    );
  }
}
