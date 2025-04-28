import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final Function(String)? onChanged;
  final String? errorText;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.obscureText = false,
    this.onChanged,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      onChanged: onChanged,
      cursorColor: Colors.white,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: Colors.grey[900],
        errorText: errorText, // Show error message
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
