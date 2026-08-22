import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart';

class FavoriteServicesChips extends StatefulWidget {
  const FavoriteServicesChips({
    super.key,
    required this.catalogItems,
    required this.initialFavoriteServices,
    required this.onSelectionChanged,
  });

  final List<CatalogItem> catalogItems;
  final List<CatalogItem> initialFavoriteServices;
  final ValueChanged<List<CatalogItem>> onSelectionChanged;

  @override
  State<FavoriteServicesChips> createState() => _FavoriteServicesChipsState();
}

class _FavoriteServicesChipsState extends State<FavoriteServicesChips> {
  late List<CatalogItem> _selectedServices;

  @override
  void initState() {
    super.initState();
    _selectedServices = List.from(widget.initialFavoriteServices);
  }

  void _onSelectService(bool selected, CatalogItem catalogItem) {
    setState(() {
      if (selected) {
        _selectedServices.add(catalogItem);
      } else {
        _selectedServices.remove(catalogItem);
      }
    });
    widget.onSelectionChanged(_selectedServices);
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: KaziInsets.md,
      runSpacing: KaziInsets.md,
      children: widget.catalogItems
          .map(
            (type) => ChoiceChip(
              label: Text(type.name),
              selected: _selectedServices.contains(type),
              onSelected: (selected) => _onSelectService(selected, type),
            ),
          )
          .toList(),
    );
  }
}
