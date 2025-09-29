import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyUtil {
  static final _formatter = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  static String format(int value) {
    return _formatter.format(value);
  }

  static int parse(String value) {
    final numericString = value.replaceAll(RegExp(r'[^0-9]'), '');

    return int.tryParse(numericString) ?? 0;
  }
}

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final numericString = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (numericString.isEmpty) {
      return TextEditingValue(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    final int value = int.parse(numericString);
    final newText = CurrencyUtil.format(value);

    final selectionIndex = newText.length;

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: selectionIndex.clamp(0, newText.length),
      ),
    );
  }
}
