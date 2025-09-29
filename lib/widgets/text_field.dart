import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget textField(
  String label,
  TextEditingController controller, {
  TextInputFormatter? inputFormatter,
  int? maxLines,
  FormFieldValidator? validator,
  TextInputType? keyboardType,
}) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[700]),
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    inputFormatters: inputFormatter != null ? [inputFormatter] : [],
    maxLines: maxLines,
    validator: validator,
    keyboardType: keyboardType,
  );
}
