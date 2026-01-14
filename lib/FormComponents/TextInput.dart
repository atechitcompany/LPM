import 'package:flutter/material.dart';

class TextInput extends StatefulWidget {
  final String label;
  final String hint;
  final String? initialValue;
  final TextEditingController controller;

  const TextInput({
    super.key,
    required this.label,
    required this.hint,
    this.initialValue,
    required this.controller,
  });

  @override
  State<TextInput> createState() => _TextInputState();
}

class _TextInputState extends State<TextInput> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.initialValue ?? "");
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            hintText: widget.hint,
          ),
        ),
      ],
    );
  }
}
