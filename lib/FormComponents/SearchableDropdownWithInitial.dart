import 'package:flutter/material.dart';

class SearchableDropdownWithInitial extends StatefulWidget {
  final String label;
  final List<String> items;
  final String? initialValue;     // 👈 NEW
  final Function(String) onChanged;

  const SearchableDropdownWithInitial({
    super.key,
    required this.label,
    required this.items,
    required this.onChanged,
    this.initialValue,
  });

  @override
  State<SearchableDropdownWithInitial> createState() =>
      _SearchableDropdownWithInitialState();
}

class _SearchableDropdownWithInitialState
    extends State<SearchableDropdownWithInitial> {
  final TextEditingController controller = TextEditingController();
  List<String> filtered = [];
  bool expanded = false;

  @override
  void initState() {
    super.initState();

    filtered = widget.items;

    // 👈 If initial value exists, set it
    if (widget.initialValue != null &&
        widget.initialValue!.isNotEmpty &&
        widget.items.contains(widget.initialValue)) {
      controller.text = widget.initialValue!;
      filterItems(widget.initialValue!);
    }
  }

  void filterItems(String query) {
    setState(() {
      filtered = widget.items
          .where((item) =>
          item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
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
        const SizedBox(height: 8),

        // TextField
        TextField(
          controller: controller,
          onTap: () => setState(() => expanded = true),
          onChanged: (value) => filterItems(value),
          decoration: InputDecoration(
            hintText: "Field text goes here",
            suffixIcon: const Icon(Icons.arrow_drop_down),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),

        // Dropdown List
        if (expanded)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD2D5DA)),
              borderRadius: BorderRadius.circular(6),
              color: Colors.white,
            ),
            constraints: const BoxConstraints(maxHeight: 180),
            child: filtered.isEmpty
                ? const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text("No results"),
            )
                : ListView(
              padding: EdgeInsets.zero,
              children: filtered
                  .map(
                    (item) => ListTile(
                  title: Text(item),
                  onTap: () {
                    controller.text = item;
                    widget.onChanged(item);
                    setState(() => expanded = false);
                  },
                ),
              )
                  .toList(),
            ),
          ),
      ],
    );
  }
}
