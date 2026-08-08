import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart';

class KaziPageTitle extends StatelessWidget {
  const KaziPageTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.searchLabel,
    this.onFilter,
    this.onSearchChanged,
    this.searchController,
  });
  final String title;
  final String? subtitle;
  final String? searchLabel;
  final VoidCallback? onFilter;
  final ValueChanged<String>? onSearchChanged;
  final TextEditingController? searchController;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorsScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: KaziInsets.xLg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: KaziTextStyles.headlineLg,
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: KaziTextStyles.lg.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          Row(
            children: [
              if (searchLabel != null)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 280),
                  child: KaziTextFormField(
                    labelText: searchLabel!,
                    prefixIcon: const Icon(Icons.search),
                    controller: searchController,
                    onChanged: onSearchChanged,
                  ),
                ),
              if (onFilter != null)
                Padding(
                  padding: const EdgeInsets.only(left: KaziInsets.md),
                  child: KaziElevatedButton.icon(
                    onTap: onFilter!,
                    icon: const Icon(Icons.filter_alt),
                    label: KaziLocalizations.current.filters,
                    backgroundColor: colors.surfaceContainerHigh,
                    foregroundColor: colors.onSurface,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
