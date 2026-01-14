import 'package:flutter/material.dart';

class FlexibleToggle extends StatefulWidget {
  final String label;
  final String inactiveText;      // Example: "Pending"
  final String activeText;        // Example: "Done"
  final bool initialValue;
  final Function(bool) onChanged;

  const FlexibleToggle({
    super.key,
    required this.label,
    required this.inactiveText,
    required this.activeText,
    required this.onChanged,
    this.initialValue = false,
  });

  @override
  State<FlexibleToggle> createState() => _FlexibleToggleState();
}

class _FlexibleToggleState extends State<FlexibleToggle> {
  late bool value;

  @override
  void initState() {
    value = widget.initialValue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),

        /// Outer container like your screenshot
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 55,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// LEFT TEXT changes dynamically (Pending <-> Done)
              Text(
                value ? widget.activeText : widget.inactiveText,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.black87,
                ),
              ),

              /// RIGHT TOGGLE BUTTON
              GestureDetector(
                onTap: () {
                  setState(() => value = !value);
                  widget.onChanged(value);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 55,
                  height: 28,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: value ? Colors.yellow : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Align(
                    alignment:
                    value ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: value
                          ? const Icon(Icons.check, size: 16, color: Colors.yellow)
                          : const Icon(Icons.close, size: 16, color: Colors.yellow),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
