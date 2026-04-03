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
  late TextEditingController _internalController;

  @override
  void initState() {
    debugPrint("🔢 NumberStepper initState — controller.text=${widget.controller.text}, initialValue=${widget.initialValue}");
    super.initState();

    // ✅ Use external controller value if it has data, else use initialValue
    final externalVal = double.tryParse(widget.controller.text);
    value = externalVal ?? widget.initialValue;
    _internalController = TextEditingController(text: formatNumber(value));

    // ✅ ADD THIS — sync initial value back to external controller
    widget.controller.text = formatNumber(value);

    // ✅ Listen to external controller changes
    widget.controller.addListener(_onExternalControllerChanged);
  }

  // ✅ THIS IS THE KEY FIX — when parent sets controller.text, update internal state
  void _onExternalControllerChanged() {
    debugPrint("🔢 Listener fired — controller.text=${widget.controller.text}, current value=$value");
    final externalVal = double.tryParse(widget.controller.text);
    if (externalVal != null && externalVal != value) {
      debugPrint("🔢 Updating value to $externalVal");
      setState(() {
        value = externalVal;
        _internalController.text = formatNumber(value);
      });
    }
  }

  @override
  void didUpdateWidget(NumberStepper oldWidget) {
    super.didUpdateWidget(oldWidget);

    // ✅ If controller instance changed, re-attach listener
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(_onExternalControllerChanged);
      widget.controller.addListener(_onExternalControllerChanged);

      final externalVal = double.tryParse(widget.controller.text);
      if (externalVal != null) {
        setState(() {
          value = externalVal;
          _internalController.text = formatNumber(value);
        });
      }
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onExternalControllerChanged);
    _internalController.dispose();
    super.dispose();
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
      widget.controller.text = formatNumber(parsed); // ✅ sync external controller
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
              controller: _internalController,
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
                    _internalController.text = formatNumber(value);
                    widget.controller.text = formatNumber(value); // ✅ sync
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
                    _internalController.text = formatNumber(value);
                    widget.controller.text = formatNumber(value); // ✅ sync
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