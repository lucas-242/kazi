import 'package:flutter/widgets.dart';
import 'package:kazi_core/shared/themes/settings/kazi_text_styles.dart';

class KaziError extends StatelessWidget {
  const KaziError({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message, style: KaziTextStyles.titleSmall),
    );
  }
}
