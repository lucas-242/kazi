import 'package:flutter/material.dart';

/// A sentence with one substring in bold — the name the sentence is about.
///
/// A warning like "Já existe **Ana Prado** com 7 serviços" is scanned for the
/// name, not read; bolding it is what lets someone answer without reading the
/// rest. The sentence stays a single localized string, because splitting it
/// into fragments to style them puts word order in the layout's hands and
/// breaks the moment a translation moves the name.
class KaziEmphasizedText extends StatelessWidget {
  const KaziEmphasizedText(
    this.text, {
    super.key,
    required this.emphasis,
    this.style,
    this.textAlign,
  });

  final String text;

  /// The substring to bold. Matched once, literally; a value that does not
  /// occur in [text] leaves the sentence plain.
  final String emphasis;

  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final start = emphasis.isEmpty ? -1 : text.indexOf(emphasis);
    if (start < 0) return Text(text, style: style, textAlign: textAlign);

    final end = start + emphasis.length;

    return Text.rich(
      TextSpan(
        text: text.substring(0, start),
        children: [
          TextSpan(
            text: emphasis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: text.substring(end)),
        ],
      ),
      style: style,
      textAlign: textAlign,
    );
  }
}
