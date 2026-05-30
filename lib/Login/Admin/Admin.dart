import 'package:flutter/material.dart';
import 'package:lightatech/Features/Dashboard/screens/sidebar_menu.dart';
import 'package:lightatech/Features/Dashboard/widgets/dashboard_appbar.dart';
// --- BEGIN ADMIN DASHBOARD OVERVIEW SECTIONS ---
import 'package:lightatech/Features/adminAccess/widgets/admin_dashboard_overview.dart';
// --- END ADMIN DASHBOARD OVERVIEW SECTIONS ---

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

// --- BEGIN ADMIN DASHBOARD OVERVIEW SECTIONS ---
      body: AdminDashboardOverview(searchText: searchController.text),
// --- END ADMIN DASHBOARD OVERVIEW SECTIONS ---
    );
  }
// --- END ADMIN RESTRUCTURE: DEPARTMENTAL ACCESS SECTION ---
}