import 'package:flutter/material.dart';

class DividerWithText extends StatelessWidget {
  final String text;

  const DividerWithText({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[700], thickness: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            text,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey[700], thickness: 1)),
      ],
    );
  }
}
