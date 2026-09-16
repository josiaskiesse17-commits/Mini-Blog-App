import 'package:flutter/material.dart';

class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.controller,
    required this.label,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final lowerLabel = label.toLowerCase();

    final icon = lowerLabel.contains('email')
        ? Icons.mail_outline_rounded
        : lowerLabel.contains('nom')
            ? Icons.person_outline_rounded
            : Icons.lock_outline_rounded;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: Theme.of(context).textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        prefixIconColor: colors.onSurfaceVariant,
      ),
    );
  }
}