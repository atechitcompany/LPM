import 'package:flutter/material.dart';

class TextInput extends StatefulWidget {
  final String label;
  final String hint;
  final String? initialValue;
  final TextEditingController controller;
  final bool readOnly;

  const TextInput({
    super.key,
    required this.label,
    required this.hint,
    required this.controller,
    this.initialValue,
    this.readOnly = false,
  });

  @override
  State<TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // ✅ Apply initialValue ONLY ONCE
    if (!_initialized && widget.initialValue != null && widget.controller.text.isEmpty) {
      widget.controller.text = widget.initialValue!;
    }

    _initialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: widget.controller,
          readOnly: widget.readOnly,
          decoration: InputDecoration(
            hintText: widget.hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            filled: widget.readOnly,
            fillColor: widget.readOnly ? Colors.grey.shade100 : null,
          ),
        ),
      ],
    );
  }
}
