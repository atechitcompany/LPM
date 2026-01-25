import 'package:flutter/material.dart';

class FloatingButton extends StatelessWidget {
  final VoidCallback onPressed;

  const FloatingButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,

      // ✅ REMOVE ALL SHADOW / ELEVATION
      elevation: 0,
      highlightElevation: 0,
      focusElevation: 0,
      hoverElevation: 0,

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
