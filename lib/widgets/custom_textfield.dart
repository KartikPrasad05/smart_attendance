import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final IconData? icon;
  final TextInputType inputType;

  const CustomTextField({
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.icon,
    this.inputType = TextInputType.text,
    super.key,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    final isPassword = widget.obscure;

    return TextField(
      controller: widget.controller,
      keyboardType: widget.inputType,
      obscureText: isPassword && !showPassword,
      decoration: InputDecoration(
        hintText: widget.hint,
        filled: true,
        fillColor: Colors.grey.shade200,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),

        // PREFIX ICON
        prefixIcon: widget.icon != null
            ? Icon(widget.icon, color: Colors.deepPurple)
            : null,

        // PASSWORD TOGGLE
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  showPassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.deepPurple,
                ),
                onPressed: () => setState(() => showPassword = !showPassword),
              )
            : null,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
