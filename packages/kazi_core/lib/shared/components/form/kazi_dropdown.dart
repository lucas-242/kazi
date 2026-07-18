import 'package:flutter/material.dart';
import 'package:kazi_core/kazi_core.dart';

/// A dropdown-style selector built on top of [KaziTextFormField] and a modal
/// bottom sheet, following the app's visual patterns (no third-party lib).
///
/// The field is read-only and opens a bottom sheet with the available [items]
/// (optionally searchable via [showSeach]). When [validator] is `null` the
/// selection is optional and a clear button is shown once something is picked,
/// letting the user deselect (emits `onChanged(null)`).
class KaziDropdown extends StatefulWidget {
  const KaziDropdown({
    super.key,
    required this.label,
    required this.hint,
    this.selectedItem,
    required this.items,
    this.validator,
    this.onChanged,
    this.showSeach = false,
    this.searchHint,
    required this.searchLabel,
    required this.noResultsLabel,
  });
  final String label;
  final String hint;
  final DropdownItem? selectedItem;
  final List<DropdownItem> items;
  final String? Function(DropdownItem?)? validator;
  final Function(DropdownItem?)? onChanged;
  final bool showSeach;
  final String? searchHint;
  final String searchLabel;
  final String noResultsLabel;

  @override
  State<KaziDropdown> createState() => _KaziDropdownState();
}

class _KaziDropdownState extends State<KaziDropdown> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.selectedItem?.label ?? '');
  }

  @override
  void didUpdateWidget(covariant KaziDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedItem != widget.selectedItem) {
      _controller.text = widget.selectedItem?.label ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isOptional => widget.validator == null;

  bool get _hasSelection {
    final item = widget.selectedItem;
    return item != null && item.label.isNotEmpty;
  }

  Future<void> _openPicker() async {
    final selected = await showModalBottomSheet<DropdownItem>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (_) => _KaziDropdownPicker(
        title: widget.label,
        items: widget.items,
        selectedItem: widget.selectedItem,
        showSearch: widget.showSeach,
        searchHint: widget.searchHint,
        searchLabel: widget.searchLabel,
        noResultsLabel: widget.noResultsLabel,
      ),
    );
    if (selected != null) {
      widget.onChanged?.call(selected);
    }
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call(null);
  }

  @override
  Widget build(BuildContext context) {
    final showClear = _isOptional && _hasSelection;
    return KaziTextFormField(
      labelText: widget.hint,
      controller: _controller,
      readOnly: true,
      onTap: _openPicker,
      validator: widget.validator == null
          ? null
          : (_) => widget.validator!(widget.selectedItem),
      suffixIcon: showClear
          ? IconButton(
              icon: const Icon(Icons.close),
              onPressed: _clear,
            )
          : const Icon(Icons.keyboard_arrow_down_outlined),
    );
  }
}

/// Bottom-sheet content that lists the [items], optionally with a search box,
/// and pops the chosen [DropdownItem] back to [KaziDropdown].
class _KaziDropdownPicker extends StatefulWidget {
  const _KaziDropdownPicker({
    required this.title,
    required this.items,
    required this.selectedItem,
    required this.showSearch,
    required this.searchHint,
    required this.searchLabel,
    required this.noResultsLabel,
  });
  final String title;
  final List<DropdownItem> items;
  final DropdownItem? selectedItem;
  final bool showSearch;
  final String? searchHint;
  final String searchLabel;
  final String noResultsLabel;

  @override
  State<_KaziDropdownPicker> createState() => _KaziDropdownPickerState();
}

class _KaziDropdownPickerState extends State<_KaziDropdownPicker> {
  late List<DropdownItem> _filtered;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String value) {
    final query = value.trim().toLowerCase();
    setState(() {
      _filtered = query.isEmpty
          ? widget.items
          : widget.items
              .where((item) => item.label.toLowerCase().contains(query))
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: context.height * 0.7),
      child: Padding(
        padding: EdgeInsets.only(
          top: KaziInsets.xLg,
          left: KaziInsets.xLg,
          right: KaziInsets.xLg,
          bottom: KaziInsets.lg + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.title, style: KaziTextStyles.titleMd),
            KaziSpacings.verticalLg,
            if (widget.showSearch) ...[
              KaziTextFormField(
                labelText: widget.searchLabel,
                hintText: widget.searchHint ?? widget.searchLabel,
                onChanged: _onSearch,
                prefixIcon: const Icon(Icons.search),
              ),
              KaziSpacings.verticalMd,
            ],
            if (_filtered.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: KaziInsets.md),
                child: Text(
                  widget.noResultsLabel,
                  style: KaziTextStyles.titleSm,
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = _filtered[index];
                    final isSelected = item == widget.selectedItem;
                    return ColoredBox(
                      color: isSelected
                          ? KaziColors.lightYellow
                          : Colors.transparent,
                      child: ListTile(
                        title: Text(item.label, style: KaziTextStyles.md),
                        trailing: isSelected
                            ? Icon(
                                Icons.check,
                                color: context.colorsScheme.primary,
                              )
                            : null,
                        onTap: () => Navigator.of(context).pop(item),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
