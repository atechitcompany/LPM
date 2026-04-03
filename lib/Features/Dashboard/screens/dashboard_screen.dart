import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../screens/sidebar_menu.dart';
import '../widgets/dashboard_appbar.dart';
import '../widgets/activity_list_firestore.dart';
import 'package:lightatech/FormComponents/FLoatingButton.dart';
import 'package:lightatech/core/theme/theme_provider.dart';

class DashboardScreen extends StatefulWidget {
  final String department;
  final String email;

  const DashboardScreen({
    super.key,
    required this.department,
    required this.email,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final searchController = TextEditingController();
  String _normalizeDepartment(String dept) {
    final cleanDept = dept.replaceAll(" ", "").toLowerCase();
    switch (cleanDept) {
      case "lasercut":
        return "LaserCutting";
      case "autobending":
        return "AutoBending";
      case "manualbending":
        return "ManualBending";
      case "designer":
        return "Designer";
      default:
        return dept;
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2FF),
      drawer: SidebarMenu(),
      appBar: DashboardAppBar(
        showBack: false,
        department: widget.department,
        onBack: () {},
      ),
      body: Column(
        children: [
          // ── Search bar merged with filter ──────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  const _ThinSearchIcon(size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search for..',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  // ── Yellow filter button ───────────────────────────────
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Advanced filters coming soon!'),
                        ),
                      );
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      margin: const EdgeInsets.only(right: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8D94B),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Firebase Jobs List (tabs inside) ───────────────────────────
          Expanded(
            child: ActivityListFirestore(
              searchText: searchController.text,
              department: _normalizeDepartment(widget.department),
            ),
          ),
        ],
      ),

      // ── Floating Add Button ────────────────────────────────────────────
      floatingActionButton: widget.department == 'Designer'
          ? SizedBox(
              width: 46,
              height: 46,
              child: FloatingActionButton(
                onPressed: () {
                  context.push(
                    '/jobform',
                    extra: {'department': 'Designer', 'email': widget.email},
                  );
                },
                backgroundColor: const Color(0xFFF8D94B),
                elevation: 4,
                shape: const CircleBorder(),
                child: const Icon(Icons.add, color: Colors.white, size: 22),
              ),
            )
          : null,
    );
  }
}

class ShadowWrapper extends StatelessWidget {
  final Widget child;
  const ShadowWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            spreadRadius: 0.1,
            offset: const Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}

//Login Parsing to be done

class _ThinSearchIcon extends StatelessWidget {
  final double size;
  final Color color;
  const _ThinSearchIcon({this.size = 22, this.color = Colors.black});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SearchIconPainter(color: color),
    );
  }
}

class _SearchIconPainter extends CustomPainter {
  final Color color;
  _SearchIconPainter({this.color = Colors.black});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double r = size.width * 0.35;
    final Offset center = Offset(size.width * 0.42, size.height * 0.42);

    // Circle
    canvas.drawCircle(center, r, paint);

    // Handle line
    final double angle = 3.14159 / 4; // 45 degrees
    final Offset lineStart = Offset(
      center.dx + r * 0.707,
      center.dy + r * 0.707,
    );
    final Offset lineEnd = Offset(
      lineStart.dx + size.width * 0.22,
      lineStart.dy + size.height * 0.22,
    );
    canvas.drawLine(lineStart, lineEnd, paint);
  }

  @override
  bool shouldRepaint(_SearchIconPainter oldDelegate) => false;
}
