import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddableSearchDropdown extends StatefulWidget {
  final String label;
  final List<String>? items;
  final Function(String) onChanged;
  final Function(String) onAdd;
  final String? initialValue;
  final String? firestoreCollection;
  final String? firestoreField;

  const AddableSearchDropdown({
    super.key,
    required this.label,
    this.items,
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
  List<String> _fetchedItems = [];
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    _fetchFromFirestore().then((_) {
      _applyInitialValue(widget.initialValue);
    });
  }

  @override
  void didUpdateWidget(AddableSearchDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != controller.text) {
      _applyInitialValue(widget.initialValue);
    }
  }

  void _applyInitialValue(String? value) {
    if (value == null || value.isEmpty || value.trim() == "No") {
      controller.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onChanged("No");
      });
    } else {
      controller.text = value.trim();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onChanged(value.trim());
      });
    }
  }

  Future<void> _fetchFromFirestore() async {
    if (widget.firestoreCollection == null || widget.firestoreField == null) return;

    if (mounted) setState(() => _isFetching = true);

    try {
      final query = await FirebaseFirestore.instance
          .collection(widget.firestoreCollection!)
          .get();

      final List<String> fetched = [];
      for (final doc in query.docs) {
        final value = doc.data()[widget.firestoreField!]?.toString() ?? '';
        if (value.isNotEmpty) fetched.add(value);
      }
      fetched.sort();

      if (mounted) {
        setState(() {
          _fetchedItems = fetched;
          _isFetching = false;
        });
      }
    } catch (e) {
      debugPrint("❌ Error fetching from Firestore: $e");
      if (mounted) setState(() => _isFetching = false);
    }
  }

  /// ✅ Called on form submit OR when user finishes typing a new value
  Future<void> saveToFirestoreIfNew(String value) async {
    if (widget.firestoreCollection == null || widget.firestoreField == null) return;

    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == "No") return;

    // ✅ Skip if already exists in DB
    final alreadyExists = _mergedItems.any(
          (e) => e.toLowerCase() == trimmed.toLowerCase(),
    );
    if (alreadyExists) return;

    setState(() => _isSaving = true);
    try {
      await FirebaseFirestore.instance
          .collection(widget.firestoreCollection!)
          .add({widget.firestoreField!: trimmed});

      debugPrint("✅ Auto-saved '$trimmed' to ${widget.firestoreCollection}");

      if (mounted) {
        setState(() {
          _fetchedItems.add(trimmed);
          _fetchedItems.sort();
        });
      }

      widget.onAdd(trimmed);
    } catch (e) {
      debugPrint("❌ Error saving to Firestore: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String get effectiveValue {
    final text = controller.text.trim();
    return text.isEmpty ? "No" : text;
  }

  List<String> get _mergedItems {
    return {
      ...?widget.items,
      ..._fetchedItems,
    }.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> safeItems = _mergedItems;

    final List<String> filtered = safeItems
        .where((e) => e.toLowerCase().contains(controller.text.toLowerCase()))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),

        TextField(
          controller: controller,
          onTap: () => setState(() => expanded = true),
          onChanged: (val) {
            setState(() {});
            // ✅ Notify parent with current typed value immediately
            widget.onChanged(val.trim().isEmpty ? "No" : val.trim());
          },
          // ✅ When user presses done/next on keyboard — auto-save if new value
          onSubmitted: (val) async {
            final trimmed = val.trim();
            if (trimmed.isNotEmpty) {
              await saveToFirestoreIfNew(trimmed);
              widget.onChanged(trimmed);
            }
            setState(() => expanded = false);
          },
          // ✅ When field loses focus — auto-save if new value
          onEditingComplete: () async {
            final trimmed = controller.text.trim();
            if (trimmed.isNotEmpty) {
              await saveToFirestoreIfNew(trimmed);
              widget.onChanged(trimmed);
            }
            setState(() => expanded = false);
            FocusScope.of(context).unfocus();
          },
          decoration: InputDecoration(
            hintText: "Search or type to add...",
            helperStyle: const TextStyle(color: Colors.grey, fontSize: 11),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            suffixIcon: _isFetching || _isSaving
                ? const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
                : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ✅ Clear button — only when text is present
                if (controller.text.isNotEmpty)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 18),
                    onPressed: () {
                      controller.clear();
                      widget.onChanged("No");
                      setState(() {});
                    },
                  ),
                // ✅ Arrow toggle — always visible, rotates when expanded
                IconButton(
                  icon: AnimatedRotation(
                    turns: expanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down),
                  ),
                  onPressed: () => setState(() => expanded = !expanded),
                ),
              ],
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
            child: _isFetching
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

                // ✅ No results and nothing typed
                if (filtered.isEmpty && controller.text.trim().isEmpty)
                  const ListTile(
                    title: Text(
                      "No items found",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),

                // ✅ Show "will be added" hint when typing something new
                if (controller.text.trim().isNotEmpty &&
                    !safeItems.any((e) =>
                    e.toLowerCase() ==
                        controller.text.trim().toLowerCase()))
                  ListTile(
                    leading: _isSaving
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.info_outline, color: Colors.blue),
                    title: Text(
                      "'${controller.text.trim()}' will be saved on submit",
                      style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 13,
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