import 'package:flutter/material.dart';

class FloatingButton extends StatelessWidget {
  final VoidCallback onPressed;

  const FloatingButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: Colors.yellow,
      shape: const CircleBorder(),
      child: const Icon(
        Icons.add,
        color: Colors.brown,
        size: 35,
      ),
    );
  }
}