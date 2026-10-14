import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// TextFormField dengan gaya seragam (label, ikon, validator).
class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final int? maxLength;
  final String? prefixText;
  final ValueChanged<String>? onChanged;
  final TextInputAction textInputAction;
  final bool enabled;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.maxLines = 1,
    this.maxLength,
    this.prefixText,
    this.onChanged,
    this.textInputAction = TextInputAction.next,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        maxLines: maxLines,
        maxLength: maxLength,
        onChanged: onChanged,
        enabled: enabled,
        textInputAction: maxLines > 1 ? TextInputAction.newline : textInputAction,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixText: prefixText,
          alignLabelWithHint: maxLines > 1,
          prefixIcon: icon == null ? null : Icon(icon),
        ),
      ),
    );
  }
}
