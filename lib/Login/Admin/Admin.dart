import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lightatech/routes/app_route_constants.dart';
import 'package:lightatech/Features/Dashboard/screens/sidebar_menu.dart';
import 'package:lightatech/Features/Dashboard/widgets/dashboard_appbar.dart';

class Admin extends StatefulWidget {
  const Admin({super.key});

  @override
  State<Admin> createState() => _AdminState();
}

class _AdminState extends State<Admin> {
  final TextEditingController searchController = TextEditingController();

// --- BEGIN ADMIN RESTRUCTURE: DEPARTMENTAL ACCESS SECIION ---
// approve and reject functions moved to departmental_access_screen.dart
// --- END ADMIN RESTRUCTURE: DEPARTMENTAL ACCESS SECTION ---

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

// _buildSearchBar removed as part of departmental access restructure

// --- BEGIN ADMIN RESTRUCTURE: DEPARTMENTAL ACCESS SECIION ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2FF),
      drawer: const SidebarMenu(),

      appBar: DashboardAppBar(
        showBack: false,
        department: 'Admin',
        onBack: () {},
        searchController: searchController,
        onSearchChanged: (value) {
          setState(() {});
        },
      ),

      body: const Center(
        child: Text(
          "Admin Dashboard",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
// --- END ADMIN RESTRUCTURE: DEPARTMENTAL ACCESS SECTION ---
}