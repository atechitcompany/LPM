import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final ValueChanged<int>? onNavTap;
  final int currentIndex;


  const BottomNavBar({
    super.key,
    required this.currentIndex,

    this.onNavTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main navigation row
        Container(
          color: const Color(0xFFFFFFFF),
          padding: const EdgeInsets.symmetric(vertical: 9),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🏠 Home
              GestureDetector(
                onTap: () => onNavTap?.call(0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: currentIndex == 0 ? const Color(0xFFF8D94B) : Colors.transparent,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  margin: const EdgeInsets.only(right:14,left: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: currentIndex == 0 ? 5 : 0),
                        width: 32,
                        height: 32,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.network(
                            "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/Xd0dxlEGLO/a3gw2dzp_expires_30_days.png",
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      if (currentIndex == 0)
                        const Text(
                          "Home",
                          style: TextStyle(
                            color: Color(0xFF46000A),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // 📍 Map
              GestureDetector(
                onTap: () => onNavTap?.call(1),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: currentIndex == 1 ? const Color(0xFFF8D94B) : Colors.transparent,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  margin: const EdgeInsets.only(right: 28),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: currentIndex == 1 ? 5 : 0),
                        width: 50,
                        height: 40,
                        child: Image.network(
                          "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/Xd0dxlEGLO/34lqaltj_expires_30_days.png",
                          fit: BoxFit.fill,
                        ),
                      ),
                      if (currentIndex == 1)
                        const Text(
                          "Map",
                          style: TextStyle(
                            color: Color(0xFF46000A),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // 💬 Chat
              GestureDetector(
                onTap: () => onNavTap?.call(2),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: currentIndex == 2 ? const Color(0xFFF8D94B) : Colors.transparent,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  margin: const EdgeInsets.only(right: 28),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: currentIndex == 2 ? 5 : 0),
                        width: 50,
                        height: 40,
                        child: Image.network(
                          "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/Xd0dxlEGLO/myq0jr9j_expires_30_days.png",
                          fit: BoxFit.fill,
                        ),
                      ),
                      if (currentIndex == 2)
                        const Text(
                          "Chat",
                          style: TextStyle(
                            color: Color(0xFF46000A),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // 📊 Stats
              GestureDetector(
                onTap: () => onNavTap?.call(3),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: currentIndex == 3 ? const Color(0xFFF8D94B) : Colors.transparent,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: EdgeInsets.only(right: currentIndex == 3 ? 5 : 0),
                        width: 50,
                        height: 40,
                        child: Image.network(
                          "https://storage.googleapis.com/tagjs-prod.appspot.com/v1/Xd0dxlEGLO/7486354d_expires_30_days.png",
                          fit: BoxFit.fill,
                        ),
                      ),
                      if (currentIndex == 3)
                        const Text(
                          "Stats",
                          style: TextStyle(
                            color: Color(0xFF46000A),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          )
        ),

        // Bottom handle bar (like iOS style)
        Container(
          color: const Color(0xFFFFFFFF),
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: const Color(0xFFB8BFC8),
            ),
            width: 135,
            height: 5,
          ),
        ),
      ],
    );
  }
}