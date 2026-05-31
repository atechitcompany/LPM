import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lightatech/core/theme/theme_provider.dart';
import 'package:lightatech/core/session/session_manager.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onNavTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onNavTap,
  });

  // static const List<IconData> _icons = [
  //   Icons.home_outlined,
  //   Icons.map_outlined,
  //   Icons.chat_outlined,
  //   Icons.auto_graph_outlined,
  //   Icons.golf_course,
  // ];
  //
  // static const List<String> _labels = [
  //   "Home",
  //   "Map",
  //   "Payment",
  //   "Graph",
  //   "Target",
  // ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final dept = SessionManager.getDepartment();

    final isAdmin = dept == "Admin";
    final isAccount = dept == "Account";


    final icons = isAdmin
        ? [
      Icons.home_outlined,
      Icons.map_outlined,
      Icons.chat_outlined,
      Icons.auto_graph_outlined,
      Icons.golf_course,
    ]
        : isAccount
        ? [
      Icons.home_outlined,
      Icons.map_outlined,
      Icons.chat_outlined,
      Icons.golf_course,
    ]
        : [
      Icons.home_outlined,
      Icons.map_outlined,
      Icons.golf_course,
    ];

    final labels = isAdmin
        ? [
      "Home",
      "Map",
      "Payment",
      "Graph",
      "Target",
    ]
        : isAccount
        ? [
      "Home",
      "Map",
      "Payment",
      "Target",
    ]
        : [
      "Home",
      "Map",
      "Target",
    ];
    final isDark = themeProvider.isDarkMode;

    final bgColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final iconColor = isDark ? Colors.white : Colors.black;
    final borderColor = isDark ? Colors.grey.shade800 : Colors.black12;

    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(26),
            topRight: Radius.circular(26),
          ),
          border: Border(top: BorderSide(color: borderColor, width: 1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(icons.length, (index) {
            final isSelected = currentIndex == index;

            return Flexible(
              flex: isSelected ? 2 : 1,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => onNavTap(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: isSelected
                      ? const EdgeInsets.symmetric(horizontal: 10, vertical: 8)
                      : const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.yellowAccent.withOpacity(0.8)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icons[index],
                        size: 22,
                        color: iconColor,
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            labels[index],
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            maxLines: 1,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: iconColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}