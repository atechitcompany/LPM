import 'package:flutter/material.dart';
// import 'package:lightatech/Features/Dashboard/screens/dashboard_screen.dart';
// import 'package:lightatech/Features/MapScreen/screens/map_screen.dart';
// import 'package:lightatech/Features/Dashboard/screens/chat_screen.dart';
// import 'package:lightatech/Features/Graph/screens/graph_page.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onNavTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onNavTap,
  });

  @override
  Widget build(BuildContext context) {
    final icons = [
      Icons.home_outlined,
      Icons.map_outlined,
      Icons.chat_outlined,
      Icons.auto_graph_outlined,
      Icons.golf_course,
    ];

    final labels = ["Home", "Map", "Payment", "Graph", "Target"];

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(icons.length, (index) {
          final isSelected = currentIndex == index;

          return GestureDetector(
            onTap: () => onNavTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              padding: isSelected
                  ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
                  : const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.yellow[200]!.withOpacity(0.7)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    icons[index],
                    color: Colors.black,
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 6),
                    Text(
                      labels[index],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
