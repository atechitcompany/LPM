import 'package:flutter/material.dart';

class FlexibleSlider extends StatefulWidget {
  final double max;
  final Function(double) onChanged;

  const FlexibleSlider({super.key, required this.max, required this.onChanged});

  @override
  State<FlexibleSlider> createState() => _FlexibleSliderState();
}

class _FlexibleSliderState extends State<FlexibleSlider> {
  double value = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value.toInt().toString()),
        Slider(
          activeColor: Colors.yellow,
          value: value,
          min: 0,
          max: widget.max,
          onChanged: (v) {
            setState(() => value = v);
            widget.onChanged(v);
          },
        )
      ],
    );
  }
}
