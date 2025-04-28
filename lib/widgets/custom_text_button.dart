import 'package:flutter/material.dart';

class CustomTextButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback callback;
  final IconData? icon;

  const CustomTextButton(
      {super.key,
      required this.text,
      required this.color,
      this.icon,
      required this.callback});

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: callback,
      icon: icon != null ? Icon(icon, color: color) : const SizedBox(),
      label: Text(
        text,
        style: TextStyle(color: color, fontSize: 14),
      ),
      style: TextButton.styleFrom(padding: EdgeInsets.zero),
    );
  }
}
