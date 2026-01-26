import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lightatech/routes/app_route_constants.dart';

// Intro
import 'package:lightatech/Features/Intro/screens/splash_screen.dart';
import 'package:lightatech/Features/Intro/screens/intro_screen.dart';
import 'package:lightatech/Features/Intro/screens/biometric_screen.dart';
import 'package:lightatech/Features/Intro/screens/fill_profile_screen.dart';
import 'package:lightatech/Features/Intro/screens/create_pin_screen.dart';
import 'package:lightatech/Features/Intro/auth/screens/lets_you_in_screen.dart';

// Login / Admin
import 'package:lightatech/Login/LoginScreen.dart';
import 'package:lightatech/Login/Admin/Admin.dart';
import 'package:lightatech/core/session/session_manager.dart';


// Dashboard
import 'package:lightatech/Features/Dashboard/screens/dashboard_screen.dart';
import 'package:lightatech/Features/Dashboard/screens/home.dart';
import 'package:lightatech/Features/Dashboard/screens/job_summary_screen.dart';

// Order
import '../customer/intro/viewmodel/order_detail_view.dart';

// Job Forms
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
import 'package:lightatech/Production/JobCreation/screens/forms/account/account_page1.dart';

// Map
import 'package:lightatech/Features/MapScreen/screens/map_screen.dart';
import 'package:lightatech/Features/MapScreen/screens/task_detail_page.dart';
import 'package:lightatech/Features/MapScreen/models/task.dart';

// Graph
import 'package:lightatech/Features/Graph/screens/graph_page.dart';
import 'package:lightatech/Features/Graph/widgets/graph_form.dart';
import 'package:lightatech/Features/Graph/screens/graph_tasks_page.dart';

// Target
import 'package:lightatech/Features/Target/screens/profile_screen.dart';

// Payment
import 'package:lightatech/Features/Payment/screens/paid_screen.dart';

/// 🔑 Navigator Keys
final GlobalKey<NavigatorState> _rootNavigatorKey =
GlobalKey<NavigatorState>();

final GlobalKey<NavigatorState> _shellNavigatorKey =
GlobalKey<NavigatorState>();
String _normalizeDepartment(String d) {
  switch (d.toLowerCase()) {
    case 'designer':
      return 'Designer';
    case 'auto-bending':
      return 'AutoBending';
    case 'manual-bending':
      return 'ManualBending';
    case 'laser':
      return 'Lasercut';
    case 'emboss':
      return 'Emboss';
    case 'rubber':
      return 'Rubber';
    case 'account1':
      return 'Account';
    case 'delivery':
      return 'Delivery';
    default:
      return 'Designer';
  }
}


class AppRoutes {
  AppRoutes._();


    static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
      debugLogDiagnostics: true,
    routes: [

      /// ================= ROOT SHELL =================
    initialLocation: SessionManager.isLoggedIn() ? '/dashboard' : '/',


    routes: [
      // ✅ Login & Intro pages (outside shells)
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
        path: '/order-details',
        name: 'orderDetails',
        builder: (context, state) => OrderDetailScreen(),
      ),

      GoRoute(
        path: '/intro/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: '/intro',
        builder: (context, state) => const IntroScreen(),
      ),

      GoRoute(
        path: '/intro/biometric',
        builder: (context, state) => const BiometricScreen(),
      ),

      GoRoute(
        path: '/intro/fill-profile',
        builder: (context, state) => const FillProfileScreen(),
      ),

      GoRoute(
        path: '/intro/create-pin',
        builder: (context, state) => const CreatePinScreen(),
      ),

      GoRoute(
        path: '/auth/entry',
        builder: (context, state) => const LetsYouInScreen(),
      ),

      // ✅ DASHBOARD SHELL (Home Bottom Nav)
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return child;
        },
        routes: [

          // ================= AUTH =================
          GoRoute(
            path: '/',
            builder: (_, __) => const LoginScreen(),
          ),

          GoRoute(
            path: '/admin',
            builder: (_, __) => const Admin(),
          ),

          GoRoute(
            path: '/jobform',
            redirect: (_, __) => '/jobform/designer-1',
          ),


          // ================= JOB FORM SHELL =================
          ShellRoute(
            builder: (context, state, child) {
              final lpm = state.uri.queryParameters['lpm'];
              final mode = state.uri.queryParameters['mode'];
              final department =
                  state.pathParameters['department'] ?? 'designer';

              return NewForm(
                department: _normalizeDepartment(department),
                lpm: lpm,
                mode: mode,
                child: child,
              );
            },
            routes: [

              // redirect entry point





              // designer pages
              GoRoute(path: '/jobform/designer-1', builder: (_, __) => const DesignerPage1()),
              GoRoute(path: '/jobform/designer-2', builder: (_, __) => const DesignerPage2()),
              GoRoute(path: '/jobform/designer-3', builder: (_, __) => const DesignerPage3()),
              GoRoute(path: '/jobform/designer-4', builder: (_, __) => const DesignerPage4()),
              GoRoute(path: '/jobform/designer-5', builder: (_, __) => const DesignerPage5()),
              GoRoute(path: '/jobform/designer-6', builder: (_, __) => const DesignerPage6()),

              // departments
              GoRoute(path: '/jobform/autobending', builder: (_, __) => const AutoBendingPage()),
              GoRoute(path: '/jobform/manualbending', builder: (_, __) => const ManualBendingPage()),
              GoRoute(path: '/jobform/laser', builder: (_, __) => const LaserPage()),
              GoRoute(path: '/jobform/emboss', builder: (_, __) => const EmbossPage()),
              GoRoute(path: '/jobform/rubber', builder: (_, __) => const RubberPage()),
              GoRoute(path: '/jobform/account1', builder: (_, __) => const AccountPage()),
              GoRoute(path: '/jobform/delivery', builder: (_, __) => const DeliveryPage()),
            ],
          return Home(
            child: child,
            location: state.uri.toString(),
          );
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            name: AppRoutesName.DashboardScreen,
            builder: (context, state) {
              final data = state.extra as Map<String, dynamic>?;

              final dept = data?['department'] ?? SessionManager.getDepartment() ?? 'Unknown';
              final email = data?['email'] ?? SessionManager.getEmail() ?? '';

              return DashboardScreen(
                department: dept,
                email: email,
              );

            },
          ),

          GoRoute(
            path: '/job-summary/:lpm',
            builder: (context, state) {
              final lpm = state.pathParameters['lpm']!;
              return JobSummaryScreen(lpm: lpm);
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
            builder: (context, state) => const GraphPage(),
          ),

          GoRoute(
            path: '/target',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),

      // ✅ JOB FORM SHELL (NewForm Wrapper)
      ShellRoute(
        builder: (context, state, child) {
          final extra = state.extra as Map<String, dynamic>?;

          return NewForm(
            department: extra?['department'] ?? 'Designer',
            lpm: extra?['lpm'],
            mode: extra?['mode'],
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/jobform',
            redirect: (_, __) => '/jobform/designer-1',
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
            path: '/jobform/delivery',
            builder: (context, state) => const DeliveryPage(),
          ),
        ],
      ),

          // ================= DASHBOARD SHELL =================
          ShellRoute(
            builder: (context, state, child) {
              return Home(
                child: child,
                location: state.uri.toString(),
              );
            },
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) {
                  final data = state.extra as Map<String, dynamic>?;

                  return DashboardScreen(
                    department: data?['department'] ?? '',
                    email: data?['email'] ?? '',
                  );
                },
              ),
              GoRoute(
                path: '/job-summary/:lpm',
                builder: (context, state) =>
                    JobSummaryScreen(lpm: state.pathParameters['lpm']!),
              ),
            ],
          ),
        ],
      // ✅ Other Routes
      GoRoute(
        path: '/task',
        name: AppRoutesName.TaskDetail,
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
        builder: (context, state) => const GraphFormPage(),
      ),

      GoRoute(
        path: '/graphtasks',
        builder: (context, state) => const GraphTasksPage(),
      ),
    ],
  );
}


