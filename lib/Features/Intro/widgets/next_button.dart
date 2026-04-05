import 'package:flutter/material.dart';

class NextButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isLast;

  const NextButton({
    super.key,
    required this.onTap,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: const BoxDecoration(
          color: Color(0xFFF9D84A),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isLast ? Icons.check : Icons.arrow_forward,
          color: Colors.black,
        ),
      ),
    );
  }
}
