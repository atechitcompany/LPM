import 'package:flutter/material.dart';

class GSTSelector extends StatefulWidget {
  final String selected;
  final List<dynamic> Values;
  final Function(String) onChanged;
  const GSTSelector({super.key, required this.onChanged,
  required this.selected,
    required this.Values,
  });

  @override
  State<GSTSelector> createState() => _GSTSelectorState();
}

class _GSTSelectorState extends State<GSTSelector> {
  late String selected;
  @override
  void initState(){
    super.initState();
    selected= widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: widget.Values.map((e) {
        bool active = selected == e;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => selected = e);
              widget.onChanged(e);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: active ? Colors.yellow : Colors.white,
                border: Border.all(color: Colors.black),
              ),
              alignment: Alignment.center,
              child: Text(
                e,
                style: TextStyle(
                  color: active ? Colors.black : Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
