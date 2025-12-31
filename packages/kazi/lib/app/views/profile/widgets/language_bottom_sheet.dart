import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kazi/app/shared/extensions/extensions.dart';
import 'package:kazi_core/kazi_core.dart';

class LanguageBottomSheet extends ConsumerWidget {
  const LanguageBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveLocale = ref.watch(kaziEffectiveLocaleProvider);

    Future<void> onSelect(String languageCode) async {
      await ref
          .read(kaziLocaleControllerProvider.notifier)
          .selectLanguage(languageCode: languageCode);
      if (context.mounted) context.back();
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
                KaziLocalizations.current.language,
                style: KaziTextStyles.titleMd,
              ),
              KaziSpacings.verticalXLg,
              _LanguageTile(
                title: 'Português',
                languageCode: 'pt',
                isSelected: effectiveLocale.languageCode == 'pt',
                onTap: () => onSelect('pt'),
              ),
              const Divider(),
              _LanguageTile(
                title: 'English',
                languageCode: 'en',
                isSelected: effectiveLocale.languageCode == 'en',
                onTap: () => onSelect('en'),
              ),
              const Divider(),
              _LanguageTile(
                title: 'Español',
                languageCode: 'es',
                isSelected: effectiveLocale.languageCode == 'es',
                onTap: () => onSelect('es'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.title,
    required this.languageCode,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String languageCode;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      title: Text(
        title,
        style: isSelected ? KaziTextStyles.titleMd : KaziTextStyles.md,
      ),
      trailing: Visibility(
        visible: isSelected,
        child: Icon(Icons.check, color: context.colorsScheme.primary),
      ),
      contentPadding: EdgeInsets.zero,
    );
  }
}
