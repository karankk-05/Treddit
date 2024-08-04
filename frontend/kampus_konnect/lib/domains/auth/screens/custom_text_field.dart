// lib/widgets/custom_text_field.dart
import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool obscureText;
  final TextEditingController controller;

  CustomTextField({
    required this.icon,
    required this.label,
    this.obscureText = false,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: theme.onPrimary),
        labelText: label,
        labelStyle: TextStyle(color: theme.onSurface),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        filled: true,
        fillColor: theme.primary.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
