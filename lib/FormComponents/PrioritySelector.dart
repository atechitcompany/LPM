import 'package:flutter/material.dart';

class PrioritySelector extends StatefulWidget {
  final Function(String) onChanged;
  const PrioritySelector({super.key, required this.onChanged});

  @override
  State<PrioritySelector> createState() => _PrioritySelectorState();
}

class _PrioritySelectorState extends State<PrioritySelector> {
  String selected = "";

  List<String> items = [
    "Blade Change",
    "Important",
    "Hold",
    "Cancel",
    "Emergency"
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            bool isEmergency = item == "Emergency";
            bool active = selected == item;

            // Full width Emergency button
            if (isEmergency) {
              return SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () {
                    setState(() => selected = item);
                    widget.onChanged(item);
                  },
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(),
                      color: active ? Colors.red : Colors.white,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      item,
                      style: TextStyle(
                        color: active ? Colors.white : Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              );
            }

            // Normal smaller buttons
            return GestureDetector(
              onTap: () {
                setState(() => selected = item);
                widget.onChanged(item);
              },
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black),
                  color: active ? Colors.yellow : Colors.white,
                ),
                child: Text(
                  item,
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
