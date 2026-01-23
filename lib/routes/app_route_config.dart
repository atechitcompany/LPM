import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lightatech/Features/Intro/screens/fill_profile_screen.dart';
import 'package:lightatech/Features/Intro/screens/create_pin_screen.dart';
import 'package:lightatech/Features/Intro/screens/biometric_screen.dart';

import 'package:lightatech/Features/Intro/screens/fill_profile_screen.dart';
import 'package:lightatech/Features/Intro/screens/create_pin_screen.dart';

import 'package:lightatech/Login/Admin/Admin.dart';
import 'package:lightatech/Features/Intro/auth/screens/lets_you_in_screen.dart';
import 'package:lightatech/Login/LoginScreen.dart';
import 'package:lightatech/Production/JobCreation/screens/forms/account/account_page1.dart';
import 'package:lightatech/Production/JobCreation/screens/forms/designer/designer_page_4.dart';
// import 'package:lightatech/Production/JobCreation/screens/JobsForm.dart';
import 'package:lightatech/routes/app_route_constants.dart';
import 'package:lightatech/Production/JobCreation/screens/forms/new_form.dart';
import 'package:lightatech/Production/JobCreation/screens/forms/designer/designer_page_1.dart';
import 'package:lightatech/Production/JobCreation/screens/forms/designer/designer_page_2.dart';
import 'package:lightatech/Production/JobCreation/screens/forms/designer/designer_page_3.dart';
import 'package:lightatech/Production/JobCreation/screens/forms/designer/designer_page_4.dart';
import 'package:lightatech/Production/JobCreation/screens/forms/designer/designer_page_5.dart';
import 'package:lightatech/Production/JobCreation/screens/forms/designer/designer_page_6.dart';


import 'package:lightatech/Production/JobCreation/screens/forms/auto_bending/auto_bending_page.dart';
import 'package:lightatech/Production/JobCreation/screens/forms/manual_bending/manual_bending_page.dart';
import 'package:lightatech/Production/JobCreation/screens/forms/laser_cut/laser_page.dart';
import 'package:lightatech/Production/JobCreation/screens/forms/emboss/emboss_page.dart';
import 'package:lightatech/Production/JobCreation/screens/forms/rubber/rubber_page.dart';
import 'package:lightatech/Production/JobCreation/screens/forms/delivery/delivery_page.dart';

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

import '../customer/intro/viewmodel/order_detail_view.dart';

// New
import 'package:lightatech/Features/Dashboard/screens/job_summary_screen.dart';


/// ✅ INTRO FEATURE IMPORTS (NEW)
import 'package:lightatech/Features/Intro/screens/splash_screen.dart';
import 'package:lightatech/Features/Intro/screens/intro_screen.dart';


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
    initialLocation: '/',

    routes: [

      /* ---------------- ROOT ROUTES ---------------- */

      GoRoute(
        path: '/order-details',
        name: 'orderDetails',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>  OrderDetailScreen(),
      ),

      GoRoute(
        path: '/intro/biometric',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BiometricScreen(),
      ),


      GoRoute(
        path: '/intro/fill-profile',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const FillProfileScreen(),
      ),

      GoRoute(
        path: '/intro/create-pin',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CreatePinScreen(),
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

      /// ✅ INTRO ROUTES (ADDED SAFELY)
      GoRoute(
        path: '/intro/splash',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: '/intro',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const IntroScreen(),
      ),

      ShellRoute(
        builder: (context, state, child) {
          return NewForm(child: child);
        },
        routes: [

          // 🔹 DEFAULT ENTRY → FIRST PAGE
          GoRoute(
            path: '/jobform',
            redirect: (_, __) => '/jobform/designer-1',
          ),

          GoRoute(
            path: '/auth/entry',
            builder: (context, state) => const LetsYouInScreen(),
          ),

          GoRoute(
            path: '/jobform/designer-1',
            builder: (context, state) => const DesignerPage1(),
          ),
          GoRoute(
            path: '/jobform/designer-2',
            builder: (context, state) => const DesignerPage2(),
          ),
          GoRoute(
            path: '/jobform/designer-3',
            builder: (context, state) => const DesignerPage3(),
          ),
          GoRoute(
            path: '/jobform/designer-4',
            builder: (context, state) => const DesignerPage4(),
          ),

          GoRoute(
            path: '/jobform/designer-5',
            builder: (context, state) => const DesignerPage5(),
          ),

          GoRoute(
            path: '/jobform/designer-6',
            builder: (context, state) => const DesignerPage6(),
          ),


          GoRoute(
            path: '/jobform/auto-bending',
            builder: (context, state) => const AutoBendingPage(),
          ),
          GoRoute(
            path: '/jobform/manual-bending',
            builder: (context, state) => const ManualBendingPage(),
          ),
          GoRoute(
            path: '/jobform/laser',
            builder: (context, state) => const LaserPage(),
          ),
          GoRoute(
            path: '/jobform/rubber',
            builder: (context, state) => const RubberPage(),
          ),
          GoRoute(
            path: '/jobform/emboss',
            builder: (context, state) => const EmbossPage(),
          ),

          GoRoute(
            path: '/jobform/account1',
            builder: (context, state) => const AccountPage(),
          ),

          GoRoute(
            path: '/jobform/account2',
            builder: (context, state) => const EmbossPage(),
          ),

          GoRoute(
            path: '/jobform/delivery',
            builder: (context, state) => const DeliveryPage(),
          ),
        ],
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
            path: '/job-summary/:lpm',
            builder: (context, state) {
              final lpm = state.pathParameters['lpm']!;
              return JobSummaryScreen(lpm: lpm);
            },
          ),


          GoRoute(
            path: '/dashboard',
            name: AppRoutesName.DashboardScreen,
            builder: (context, state) {
              final data = state.extra as Map<String, dynamic>?;

              return DashboardScreen(
                department: data?['department'] ?? 'Unknown',
                email: data?['email'] ?? '',
              );
            },
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
