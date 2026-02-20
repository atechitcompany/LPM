import 'package:flutter/material.dart';

class AutoIncrementField extends StatelessWidget {
  final String value;

  const AutoIncrementField({
    super.key,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("LPM *",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              border: Border.all(),
              borderRadius: BorderRadius.circular(6)),
          child: Text(
            value,
            style: const TextStyle(
                fontSize: 16, color: Color(0xFF4B5563)),
          ),
        )
      ],
    );
  }
}
