import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart';

/// A titled block of menu options.
///
/// The groups run in the order they matter: what defines the earnings, what
/// adjusts the app, what talks about the app.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            KaziInsets.lg,
            KaziInsets.lg,
            KaziInsets.lg,
            KaziInsets.xs,
          ),
          child: Text(
            title.toUpperCase(),
            style: KaziTextStyles.tag.copyWith(
              color: context.colorsScheme.onSurfaceVariant,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}
