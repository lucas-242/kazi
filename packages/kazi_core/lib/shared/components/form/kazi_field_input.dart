import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kazi_core/shared/components/form/kazi_field.dart';
import 'package:kazi_core/shared/themes/themes.dart';

/// A typed value inside the app's [KaziField] box.
///
/// The box draws the outline, the caption and the error; the text field inside
/// it is stripped of its own decoration. It is a [FormField] rather than a
/// `TextFormField` in a box, because the box has to repaint when validation
/// fails and a `TextFormField` keeps that state to itself.
class KaziFieldInput extends StatefulWidget {
  const KaziFieldInput({
    super.key,
    required this.label,
    this.fieldKey,
    this.controller,
    this.initialValue,
    this.placeholder,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.textCapitalization = TextCapitalization.sentences,
    this.inputFormatters,
    this.maxLines = 1,
    this.autofocus = false,
    this.validator,
    this.onChanged,
    this.trailing,
  });

  final String label;
  final Key? fieldKey;
  final TextEditingController? controller;
  final String? initialValue;

  /// Shown while the field is empty. Defaults to nothing: the caption already
  /// names the field, and a placeholder repeating it is noise.
  final String? placeholder;

  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final bool autofocus;
  final String? Function(String?)? validator;
  final void Function(String value)? onChanged;
  final Widget? trailing;

  @override
  State<KaziFieldInput> createState() => _KaziFieldInputState();
}

class _KaziFieldInputState extends State<KaziFieldInput> {
  late final FocusNode _focusNode;
  late final TextEditingController _controller;
  TextEditingController? _ownController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_onFocusChange);
    _ownController = widget.controller == null
        ? TextEditingController(text: widget.initialValue ?? '')
        : null;
    _controller = widget.controller ?? _ownController!;
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_onFocusChange)
      ..dispose();
    _ownController?.dispose();
    super.dispose();
  }

  void _onFocusChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return FormField<String>(
      key: widget.fieldKey,
      initialValue: _controller.text,
      validator: widget.validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (field) => KaziField(
        label: widget.label,
        isFocused: _focusNode.hasFocus,
        errorText: field.errorText,
        onTap: _focusNode.requestFocus,
        trailing: widget.trailing,
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction,
          textCapitalization: widget.textCapitalization,
          inputFormatters: widget.inputFormatters,
          maxLines: widget.maxLines,
          style: KaziTextStyles.bodyLarge.copyWith(
            color: colors.text,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
          decoration: InputDecoration(
            hintText: widget.placeholder,
            hintStyle: KaziTextStyles.bodySmall.copyWith(
              color: colors.textMuted,
            ),
            contentPadding: EdgeInsets.zero,
            isCollapsed: true,
            filled: false,
            border: InputBorder.none,
            disabledBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
          ),
          onChanged: (value) {
            field.didChange(value);
            widget.onChanged?.call(value);
          },
        ),
      ),
    );
  }
}
