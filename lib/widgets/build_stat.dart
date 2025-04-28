import 'package:flutter/material.dart';

class Buildstat extends StatefulWidget {
  final int count;
  final String label;

  const Buildstat({super.key, required this.count, required this.label});

  @override
  State<Buildstat> createState() => _BuildstatState();
}

class _BuildstatState extends State<Buildstat> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("${widget.count}",
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        Text(widget.label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}
