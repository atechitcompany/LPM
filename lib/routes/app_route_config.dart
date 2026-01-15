import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:lightatech/Login/Admin/Admin.dart';
import 'package:lightatech/Login/LoginScreen.dart';
import 'package:lightatech/Production/JobCreation/screens/JobsForm.dart';
import 'package:lightatech/routes/app_route_constants.dart';

import 'package:lightatech/Features/Dashboard/screens/dashboard_screen.dart';
import 'package:lightatech/Features/Dashboard/screens/home.dart';

import 'package:lightatech/Features/MapScreen/screens/map_screen.dart';
import 'package:lightatech/Features/MapScreen/screens/task_detail_page.dart';
import 'package:lightatech/Features/MapScreen/models/task.dart';

import 'package:lightatech/Features/Graph/screens/graph_page.dart';
import 'package:lightatech/Features/Graph/widgets/graph_form.dart';
import 'package:lightatech/Features/Graph/screens/graph_tasks_page.dart';
import 'package:lightatech/Features/Target/screens/profile_screen.dart';


import 'package:lightatech/Features/Payment/screens/paid_screen.dart';
import 'package:lightatech/Features/Payment/screens/home_screen.dart';
import 'package:lightatech/Features/Payment/screens/payment_screen.dart';
import 'package:lightatech/Features/Payment/screens/add_user_screen.dart';
import 'package:lightatech/Features/Payment/screens/admin_alerts_screen.dart';
import 'package:lightatech/Features/Payment/screens/admin_notifications_screen.dart';
import 'package:lightatech/Features/Payment/screens/history_screen.dart';
import 'package:lightatech/Features/Payment/screens/import_screen.dart';
import 'package:lightatech/Features/Payment/screens/lead_detail_screen.dart';
import 'package:lightatech/Features/Payment/screens/lead_form_screen.dart';
import 'package:lightatech/Features/Payment/screens/manage_users_screen.dart';

import 'package:lightatech/Features/Payment/screens/reports_screen.dart';
import 'package:lightatech/Features/Payment/screens/request_access_screen.dart';
import 'package:lightatech/Features/Payment/screens/settings_screen.dart';
import 'package:lightatech/Features/Payment/screens/splash_screen.dart';


import '../customer/intro/screens/order_detail_screen.dart';




/// 🔑 Navigator Keys (SINGLE INSTANCE)
final GlobalKey<NavigatorState> _rootNavigatorKey =
GlobalKey<NavigatorState>();

final GlobalKey<NavigatorState> _shellNavigatorKey =
GlobalKey<NavigatorState>();

/// ✅ SINGLETON ROUTER
class AppRoutes {
  AppRoutes._(); // private constructor

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',

    routes: [

      /* ---------------- ROOT ROUTES ---------------- */

      GoRoute(
        path: '/order-details',
        name: 'orderDetails',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OrderDetailScreen(),
      ),

      GoRoute(
        path: '/',
        name: AppRoutesName.Loginroutename,
        builder: (context, state) => const LoginScreen(),
      ),

      GoRoute(
        path: '/admin',
        name: AppRoutesName.Adminroutename,
        builder: (context, state) => const Admin(),
      ),

      GoRoute(
        path: '/jobform',
        name: AppRoutesName.JobForm,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => NewForm(),
      ),

      GoRoute(
        path: '/task',
        name: AppRoutesName.TaskDetail,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final task = state.extra as Task;
          return TaskDetailPage(
            task: task,
            onChanged: () {},
            onDelete: () {},
          );
        },
      ),

      GoRoute(
        path: '/graphform',
        name: 'form',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const GraphFormPage(),
      ),

      GoRoute(
        path: '/graphtasks',
        name: 'tasks',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const GraphTasksPage(),
      ),

      //Payment routes

      /* ---------------- SHELL ROUTE ---------------- */

      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return Home(
            child: child,
            location: state.uri.toString(),
          );
        },

        routes: [

          GoRoute(
            path: '/dashboard',
            name: AppRoutesName.DashboardScreen,
            builder: (context, state) => const DashboardScreen(),
          ),

          GoRoute(
            path: '/map',
            name: AppRoutesName.MapScreen,
            builder: (context, state) => const MapScreen(title: 'Maps'),
          ),

          GoRoute(
            path: '/payment',
            name: AppRoutesName.PaymentScreen,
            builder: (context, state) => const PaidScreen(),
          ),

          GoRoute(
            path: '/graph',
            name: 'graph',
            builder: (context, state) => const GraphPage(),
          ),

          GoRoute(
            path: '/target',
            name: 'target',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],
  );
}
