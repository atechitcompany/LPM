import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/sidebar_menu.dart';
import '../widgets/activity_list_firestore.dart';
import 'package:lightatech/Features/Dashboard/widgets/dashboard_appbar.dart';

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
  final TextEditingController searchController = TextEditingController();

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
    final normalizedDepartment = _normalizeDepartment(widget.department);

    return Scaffold(
      backgroundColor: const Color(0xFFEEF2FF),
      drawer: const SidebarMenu(),

      appBar: DashboardAppBar(
        showBack: false,
        department: widget.department,
        onBack: () {},

        // ✅ CONNECT APPBAR SEARCH TO DASHBOARD LIST
        searchController: searchController,
        onSearchChanged: (value) {
          setState(() {});
        },
      ),

      body: ActivityListFirestore(
        searchText: searchController.text.trim(),
        department: normalizedDepartment,
      ),

      floatingActionButton: normalizedDepartment == 'Designer'
          ? SizedBox(
        width: 46,
        height: 46,
        child: FloatingActionButton(
          onPressed: () {
            context.push(
              '/jobform',
              extra: {
                'department': 'Designer',
                'email': widget.email,
              },
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