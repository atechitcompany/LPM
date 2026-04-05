import 'package:flutter/material.dart';

class PageIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;

  const PageIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        count,
            (index) => Container(
          margin: const EdgeInsets.only(right: 6),
          width: currentIndex == index ? 16 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: currentIndex == index
                ? const Color(0xFFF9D84A)
                : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
