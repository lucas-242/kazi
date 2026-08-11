import 'package:flutter/material.dart';
import 'package:kazi_core/shared/components/buttons/kazi_pill_button.dart';
import 'package:kazi_core/shared/themes/themes.dart';

class KaziBottomSheet extends StatelessWidget {
  const KaziBottomSheet({
    super.key,
    required this.title,
    required this.backText,
    required this.exitText,
    required this.onBack,
    required this.onClose,
  });

  final String title;
  final String backText;
  final String exitText;
  final VoidCallback onBack;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: context.height * 0.17,
      child: Padding(
        padding: const EdgeInsets.all(KaziInsets.lg),
        child: Column(
          children: [
            Text(title, style: KaziTextStyles.titleMedium),
            KaziSpacings.verticalLg,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                KaziPillButton(
                  onTap: onBack,
                  width: 75,
                  child: Text(backText),
                ),
                KaziSpacings.horizontalXLg,
                KaziPillButton(
                  onTap: onClose,
                  backgroundColor: context.colors.danger.fill,
                  width: 75,
                  child: Text(exitText),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
