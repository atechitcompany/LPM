import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchableDropdownWithInitial extends StatefulWidget {
  final String label;
  final List<String>? items;
  final String? initialValue;
  final Function(String) onChanged;
  final String? firestoreCollection;
  final String? firestoreField;

  const SearchableDropdownWithInitial({
    super.key,
    required this.label,
    this.items,
    required this.onChanged,
    this.initialValue,
    this.firestoreCollection,
    this.firestoreField,
  });

  @override
  State<SearchableDropdownWithInitial> createState() =>
      _SearchableDropdownWithInitialState();
}

class _SearchableDropdownWithInitialState
    extends State<SearchableDropdownWithInitial> {
  final TextEditingController controller = TextEditingController();
  List<String> _fetchedItems = [];
  List<String> filtered = [];
  bool expanded = false;
  bool _isFetching = false;

  @override
  void initState() {
    super.initState();
    _fetchFromFirestore().then((_) {
      _applyInitialValue(widget.initialValue);
    });
  }

  @override
  void didUpdateWidget(SearchableDropdownWithInitial oldWidget) {
    super.didUpdateWidget(oldWidget);

    // ✅ Only apply if parent pushed a genuinely new value
    // AND it differs from what the user currently has typed
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != controller.text) {
      _applyInitialValue(widget.initialValue);
    }
  }

  void _applyInitialValue(String? value) {
    if (value == null || value.isEmpty || value.trim() == "No") {
      controller.clear();
      _filterItems("");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onChanged("No");
      });
    } else {
      controller.text = value.trim();
      _filterItems(value.trim());
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
          filtered = _mergedItems;
        });
      }
    } catch (e) {
      debugPrint("❌ Error fetching from Firestore: $e");
      if (mounted) setState(() => _isFetching = false);
    }
  }

  List<String> get _mergedItems {
    return {
      ...?widget.items,
      ..._fetchedItems,
    }.toList()..sort();
  }

  String get effectiveValue {
    final text = controller.text.trim();
    return text.isEmpty ? "No" : text;
  }

  // ✅ No setState inside — just compute and assign, caller does setState
  void _filterItems(String query) {
    final results = _mergedItems
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .toList();
    if (mounted) setState(() => filtered = results);
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

        TextField(
          controller: controller,
          onTap: () => setState(() => expanded = true),
          onChanged: (value) {
            // ✅ Only filter + notify, do NOT call widget.onChanged with
            // a parent setState that would trigger didUpdateWidget mid-typing
            _filterItems(value);
            widget.onChanged(value.trim().isEmpty ? "No" : value.trim());
          },
          decoration: InputDecoration(
            hintText: "Field text goes here",
            helperStyle: const TextStyle(color: Colors.grey, fontSize: 11),
            suffixIcon: _isFetching
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
                // ✅ Arrow toggle button — always visible
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
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
        ),

        if (expanded)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD2D5DA)),
              borderRadius: BorderRadius.circular(6),
              color: Colors.white,
            ),
            constraints: const BoxConstraints(maxHeight: 180),
            child: _isFetching
                ? const Padding(
              padding: EdgeInsets.all(12),
              child: Center(child: CircularProgressIndicator()),
            )
                : filtered.isEmpty
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