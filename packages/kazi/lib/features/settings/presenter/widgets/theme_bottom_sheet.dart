import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart';

class ThemeBottomSheet extends ConsumerWidget {
  const ThemeBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // System is the answer until the person has said otherwise, and it is also
    // what is showing while the stored choice is still being read.
    final selected =
        ref.watch(kaziThemeControllerProvider).asData?.value ?? ThemeMode.system;

    Future<void> onSelect(ThemeMode mode) async {
      await ref
          .read(kaziThemeControllerProvider.notifier)
          .selectThemeMode(mode);
      if (context.mounted) KaziNavigator.pop();
    }

    return Wrap(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: KaziInsets.xLg,
            left: KaziInsets.xLg,
            right: KaziInsets.xLg,
            bottom: KaziInsets.xxxLg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                KaziLocalizations.current.theme,
                style: KaziTextStyles.titleMedium,
              ),
              KaziSpacings.verticalXLg,
              _ThemeTile(
                title: KaziLocalizations.current.themeSystem,
                isSelected: selected == ThemeMode.system,
                onTap: () => onSelect(ThemeMode.system),
              ),
              const Divider(),
              _ThemeTile(
                title: KaziLocalizations.current.themeLight,
                isSelected: selected == ThemeMode.light,
                onTap: () => onSelect(ThemeMode.light),
              ),
              const Divider(),
              _ThemeTile(
                title: KaziLocalizations.current.themeDark,
                isSelected: selected == ThemeMode.dark,
                onTap: () => onSelect(ThemeMode.dark),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(
        title,
        style: isSelected ? KaziTextStyles.titleMedium : KaziTextStyles.bodyMedium,
      ),
      trailing: Visibility(
        visible: isSelected,
        child: Icon(Icons.check, color: context.colors.brand.text),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}
