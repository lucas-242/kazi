import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KaziTextFormField extends StatelessWidget {
  const KaziTextFormField({
    super.key,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.next,
    this.textCapitalization = TextCapitalization.sentences,
    required this.labelText,
    this.prefixIcon,
    this.suffixIcon,
    this.hintText = '',
    this.initialValue,
    this.validator,
    this.controller,
    this.onChanged,
    this.inputFormatters,
    this.onTap,
    this.onEditingComplete,
    this.readOnly = false,
    this.textFormKey,
    this.maxLines = 1,
    this.maxLength,
    this.obscureText = false,
    this.focusNode,
    this.onFieldSubmitted,
    this.autofocus = false,
  });

  final TextInputType keyboardType;
  final TextInputAction textInputAction;
  final String labelText;
  final String hintText;
  final int maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? initialValue;
  final bool readOnly;
  final bool obscureText;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  final TextCapitalization textCapitalization;
  final Key? textFormKey;
  final FocusNode? focusNode;
  final void Function(String value)? onChanged;
  final void Function()? onTap;
  final void Function()? onEditingComplete;
  final void Function(String)? onFieldSubmitted;

  /// Opens the keyboard on the field as the screen appears. For a screen whose
  /// only purpose is that one field — asking someone to tap it first is a step
  /// with nothing on the other side of it.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: textFormKey,
      focusNode: focusNode,
      autofocus: autofocus,
      controller: controller,
      initialValue: initialValue,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textCapitalization: textCapitalization,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      readOnly: readOnly,
      onChanged: onChanged,
      onTap: onTap,
      onEditingComplete: onEditingComplete,
      onFieldSubmitted: onFieldSubmitted,
      maxLength: maxLength,
      maxLines: maxLines,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        counterText: '',
        labelText: labelText,
        errorMaxLines: 3,
        hintText: hintText.isEmpty ? labelText : null,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
