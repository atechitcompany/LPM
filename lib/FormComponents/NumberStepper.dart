import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumberStepper extends StatefulWidget {
  final double step;
  final double initialValue;
  final Function(double) onChanged;
  final TextEditingController controller;

  const NumberStepper({
    super.key,
    required this.step,
    required this.onChanged,
    this.initialValue = 0,
    required this.controller,
  });

  @override
  State<NumberStepper> createState() => _NumberStepperState();
}

class _NumberStepperState extends State<NumberStepper> {
  late double value;
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    value = widget.initialValue;
    controller = TextEditingController(text: formatNumber(value));
  }

  String formatNumber(double number) {
    if (number % 1 == 0) {
      return number.toInt().toString();
    } else {
      return number
          .toStringAsFixed(3)
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }
  }

  void updateValueFromText(String text) {
    if (text.isEmpty) return;
    final parsed = double.tryParse(text);
    if (parsed != null) {
      setState(() => value = parsed);
      widget.onChanged(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// LEFT SMALL BOX WITH EDITABLE VALUE
          Container(
            width: 60,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.black, width: 1),
            ),
            child: TextField(
              controller: controller,
              textAlign: TextAlign.center,
              keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.-]')),
              ],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: updateValueFromText,
            ),
          ),

          /// RIGHT SIDE BUTTONS
          Row(
            children: [
              /// PLUS
              GestureDetector(
                onTap: () {
                  setState(() {
                    value += widget.step;
                    controller.text = formatNumber(value);
                  });
                  widget.onChanged(value);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text(
                    "+",
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.yellow.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              /// MINUS
              GestureDetector(
                onTap: () {
                  setState(() {
                    value -= widget.step;
                    controller.text = formatNumber(value);
                  });
                  widget.onChanged(value);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    "-",
                    style: TextStyle(
                      fontSize: 35,
                      color: Colors.yellow.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
