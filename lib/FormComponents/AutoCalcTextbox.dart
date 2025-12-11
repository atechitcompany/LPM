import 'package:flutter/material.dart';

class AutoCalcTextBox extends StatelessWidget {
  final String label;
  final String? value;                     // Optional static value
  final TextEditingController? controller; // Optional controller
  final String hint;

  const AutoCalcTextBox({
    super.key,
    required this.label,
    this.value,
    this.controller,
    this.hint = "",
  }) : assert(
  value != null || controller != null,
  "Either 'value' or 'controller' must be provided.",
  );

  @override
  Widget build(BuildContext context) {
    final TextEditingController usedController =
        controller ?? TextEditingController(text: value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: usedController,
          readOnly: true,  // Only read-only. Do NOT disable.
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            filled: true,
            fillColor: Colors.grey.shade200, // Looks disabled
          ),
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
