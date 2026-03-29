import 'package:flutter/material.dart';

class AddableSearchDropdown extends StatefulWidget {
  final String label;
  final List<String> items;
  final Function(String) onChanged;
  final Function(String) onAdd;
  final String? initialValue;

  const AddableSearchDropdown({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    required this.onAdd,
    this.initialValue,
  });

  @override
  State<AddableSearchDropdown> createState() => _AddableSearchDropdownState();
}

class _AddableSearchDropdownState extends State<AddableSearchDropdown> {
  final TextEditingController controller = TextEditingController();
  bool expanded = false;
  List<String> filtered = [];

  @override
  void initState() {
    super.initState();

    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      controller.text = widget.initialValue!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onChanged(widget.initialValue!);
      });
    }
  }

  // ✅ THIS IS THE FIX — responds when parent sets a new initialValue
  @override
  void didUpdateWidget(AddableSearchDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != null &&
        widget.initialValue!.isNotEmpty) {
      controller.text = widget.initialValue!;
      // No setState needed — controller listener handles rebuild
    }
  }

  @override
  Widget build(BuildContext context) {
    filtered = widget.items
        .where((e) =>
        e.toLowerCase().contains(controller.text.toLowerCase()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),

        TextField(
          controller: controller,
          onTap: () => setState(() => expanded = true),
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: "Field text goes here",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),

        if (expanded)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 160),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFD2D5DA)),
            ),
            child: ListView(
              children: [
                ...filtered.map(
                      (item) => ListTile(
                    title: Text(item),
                    onTap: () {
                      controller.text = item;
                      widget.onChanged(item);
                      setState(() => expanded = false);
                    },
                  ),
                ),

                if (filtered.isEmpty)
                  ListTile(
                    title: Text("➕ Add '${controller.text}'"),
                    onTap: () {
                      widget.onAdd(controller.text);
                      widget.onChanged(controller.text);
                      setState(() => expanded = false);
                    },
                  ),
              ],
            ),
          ),
      ],
    );
  }
}