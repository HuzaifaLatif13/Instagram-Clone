import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color color;
  final bool isLoading;
  final Widget loadingWidget; // New parameter

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.color,
    required this.isLoading,
    required this.loadingWidget, // Required loading widget
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed, // Disable button when loading
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: isLoading
            ? loadingWidget // Use the provided loading widget
            : Text(
                text,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
