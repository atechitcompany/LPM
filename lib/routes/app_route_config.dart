import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lightatech/Pages/Common/department_common_page.dart';
import 'package:lightatech/Pages/Designer/Designer.dart';
import 'package:lightatech/Pages/Emboss/Embosse.dart';
// import 'package:lightatech/Pages/Login.dart';
import 'package:lightatech/Pages/Admin/Admin.dart';
import 'package:lightatech/Pages/LoginScreen.dart';
import 'package:lightatech/Pages/NewForm.dart';
import 'package:lightatech/routes/app_route_constants.dart';
import 'package:lightatech/Features/Dashboard/screens/analytics_screen.dart';
import 'package:lightatech/Features/Dashboard/screens/chat_screen.dart';
import 'package:lightatech/Features/Dashboard/screens/dashboard_screen.dart';
import 'package:lightatech/Features/Dashboard/screens/map_screen.dart';
import 'package:lightatech/Features/Dashboard/screens/home.dart';

class AppRoutes {
  final GoRouter router = GoRouter(
    initialLocation: "/",
    routes: [

      /* ---------------- AUTH / COMMON ROUTES ---------------- */
      GoRoute(
        name: AppRoutesName.Loginroutename,
        path: "/",
        pageBuilder: (context, state) =>
        const MaterialPage(child: LoginScreen()),
      ),

      GoRoute(
        name: AppRoutesName.Adminroutename,
        path: "/admin",
        pageBuilder: (context, state) =>
        const MaterialPage(child: Admin()),
      ),

      GoRoute(
        name: AppRoutesName.Designerroutename,
        path: "/designer",
        pageBuilder: (context, state) =>
        const MaterialPage(child: Designer()),
      ),

      GoRoute(
        name: AppRoutesName.Embossroutename,
        path: "/emboss",
        pageBuilder: (context, state) =>
        const MaterialPage(child: EmbossPage()),
      ),

      GoRoute(
        name: AppRoutesName.NewForm,
        path: "/newform",
        pageBuilder: (context, state) =>
        MaterialPage(child: NewForm()),
      ),

      /* ---------------- DASHBOARD SHELL ---------------- */
      ShellRoute(
        builder: (context, state, child) {
          final List<dynamic>? departments =
          state.extra as List<dynamic>?;
          return Home(
            child: child,
            location: state.uri.toString(), // ✅ important for nav highlight
            departments: departments,
          );
        },
        routes: [

          GoRoute(
            name: AppRoutesName.DashboardScreen,
            path: "/dashboard",
            builder: (context, state) => const DashboardScreen(),
          ),

          GoRoute(
            name: AppRoutesName.MapScreen,
            path: "/map",
            builder: (context, state) => const MapScreen(),
          ),

          GoRoute(
            name: AppRoutesName.ChatScreen,
            path: "/chat",
            builder: (context, state) => const ChatScreen(),
          ),

          GoRoute(
            name: AppRoutesName.AnalyticsScreen,
            path: "/analytics",
            builder: (context, state) => const AnalyticsScreen(),
          ),
        ],
      ),
    ],
  );
}
