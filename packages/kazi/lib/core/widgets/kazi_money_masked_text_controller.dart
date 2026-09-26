import 'package:flutter/material.dart';

/// A masked money input field.
///
/// Replaces `flutter_masked_text2`'s `MoneyMaskedTextController`, which has
/// two bugs that matter for this app:
///
/// 1. Clearing the field to nothing throws `FormatException` — its
///    `numberValue` getter builds `"."` (a lone decimal point with no digits
///    around it) and hands that to `double.parse`. Typing "1" after clearing
///    a field crashes the form instead of just starting a new number.
/// 2. It always inserts a decimal separator, even at `precision: 0` — every
///    currency with no cents (Guaraní, Chilean peso) shows a dangling comma
///    with nothing after it, e.g. "₲ 70.000,".
///
/// Typing fills the number from the right, like a calculator: each digit
/// pressed becomes the new last digit, pushing the rest left. This is the
/// same interaction the app already had for two-decimal currencies — only
/// the crash and the dangling separator are fixed, not the typing model.
class KaziMoneyMaskedTextController extends TextEditingController {
  KaziMoneyMaskedTextController({
    double initialValue = 0,
    this.decimalSeparator = ',',
    this.thousandSeparator = '.',
    this.rightSymbol = '',
    this.leftSymbol = '',
    this.precision = 2,
  }) {
    addListener(_onTextChanged);
    updateValue(initialValue);
  }

  final String decimalSeparator;
  final String thousandSeparator;
  final String rightSymbol;
  final String leftSymbol;
  final int precision;

  bool _isFormatting = false;

  void _onTextChanged() {
    if (_isFormatting) return;
    updateValue(numberValue);
  }

  /// The typed amount, as a plain number. Zero for an empty or mid-edit
  /// field rather than throwing — clearing the field to type a new value is
  /// a normal state, not an error.
  double get numberValue {
    final digits = _digitsOf(text);
    if (digits.isEmpty) return 0;

    final cents = int.parse(digits);
    return precision == 0 ? cents.toDouble() : cents / _scale;
  }

  int get _scale => _pow10(precision);

  static int _pow10(int exponent) {
    var result = 1;
    for (var i = 0; i < exponent; i++) {
      result *= 10;
    }
    return result;
  }

  String _digitsOf(String value) => value.replaceAll(RegExp('[^0-9]'), '');

  /// Re-renders the mask for [value] and moves the caret to just before
  /// [rightSymbol], the same place typing would leave it.
  void updateValue(double value) {
    final masked = _mask(value);
    if (masked == text) return;

    _isFormatting = true;
    text = masked;
    selection = TextSelection.collapsed(
      offset: masked.length - rightSymbol.length,
    );
    _isFormatting = false;
  }

  String _mask(double value) {
    final cents = (value * _scale).round().clamp(0, 999999999999);
    final digits = cents.toString().padLeft(precision + 1, '0');

    final wholeDigits = precision == 0
        ? digits
        : digits.substring(0, digits.length - precision);
    final decimalDigits = precision == 0
        ? ''
        : digits.substring(digits.length - precision);

    final body = precision == 0
        ? _grouped(wholeDigits)
        : '${_grouped(wholeDigits)}$decimalSeparator$decimalDigits';

    return '$leftSymbol$body$rightSymbol';
  }

  String _grouped(String digits) {
    final buffer = StringBuffer();
    final firstGroupLength = digits.length % 3 == 0 ? 3 : digits.length % 3;

    for (var i = 0; i < digits.length; i++) {
      if (i != 0 && (i - firstGroupLength) % 3 == 0) {
        buffer.write(thousandSeparator);
      }
      buffer.write(digits[i]);
    }

    return buffer.toString();
  }
}
