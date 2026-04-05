import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddableSearchDropdown extends StatefulWidget {
  final String label;
  final List<String>? items;           // ✅ nullable
  final Function(String) onChanged;
  final Function(String) onAdd;
  final String? initialValue;
  final String? firestoreCollection;
  final String? firestoreField;

  const AddableSearchDropdown({
    super.key,
    required this.label,
    this.items,                         // ✅ no longer required
    required this.onChanged,
    required this.onAdd,
    this.initialValue,
    this.firestoreCollection,
    this.firestoreField,
  });

  @override
  State<AddableSearchDropdown> createState() => _AddableSearchDropdownState();
}

class _AddableSearchDropdownState extends State<AddableSearchDropdown> {
  final TextEditingController controller = TextEditingController();
  bool expanded = false;
  bool _isSaving = false;

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

  @override
  void didUpdateWidget(AddableSearchDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != null &&
        widget.initialValue!.isNotEmpty) {
      controller.text = widget.initialValue!;
    }
  }

  Future<void> _saveToFirestore(String newValue) async {
    if (widget.firestoreCollection == null || widget.firestoreField == null) return;

    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection(widget.firestoreCollection!)
          .add({
        widget.firestoreField!: newValue,
      });

      debugPrint("✅ Saved '$newValue' to ${widget.firestoreCollection}");
    } catch (e) {
      debugPrint("❌ Error saving to Firestore: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ THE REAL FIX: always use a safe non-null list
    final List<String> safeItems = widget.items ?? <String>[];

    final List<String> filtered = safeItems
        .where((e) => e.toLowerCase().contains(controller.text.toLowerCase()))
        .toList();

    final bool isNewEntry = controller.text.trim().isNotEmpty &&
        !safeItems.any(
              (e) => e.toLowerCase() == controller.text.trim().toLowerCase(),
        );

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
            hintText: "Search or type to add...",
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
            child: safeItems.isEmpty && !isNewEntry
            // ✅ Still loading or empty collection
                ? const Padding(
              padding: EdgeInsets.all(12),
              child: Center(child: CircularProgressIndicator()),
            )
                : ListView(
              shrinkWrap: true,
              children: [
                // ✅ Matched existing items
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

                // ✅ "Add new" — only when typed text doesn't exist
                if (isNewEntry)
                  ListTile(
                    leading: _isSaving
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2),
                    )
                        : const Icon(Icons.add_circle_outline,
                        color: Colors.green),
                    title: Text(
                      "Add '${controller.text.trim()}'",
                      style: const TextStyle(color: Colors.green),
                    ),
                    onTap: _isSaving
                        ? null
                        : () async {
                      final newValue = controller.text.trim();
                      await _saveToFirestore(newValue);
                      widget.onAdd(newValue);
                      widget.onChanged(newValue);
                      setState(() => expanded = false);
                    },
                  ),

                // ✅ No match and not a new entry (e.g. empty search)
                if (filtered.isEmpty && !isNewEntry && safeItems.isNotEmpty)
                  const ListTile(
                    title: Text(
                      "No items found",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}