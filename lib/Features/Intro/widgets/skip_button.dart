import 'package:flutter/material.dart';

class SkipButton extends StatelessWidget {
  final VoidCallback onTap;

  const SkipButton({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      child: const Text(
        "Skip",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
