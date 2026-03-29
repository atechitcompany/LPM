import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lightatech/routes/app_route_constants.dart';
import 'package:lightatech/Production/JobCreation/screens/forms/account/account_form_flow.dart';
import 'package:lightatech/Production/JobCreation/screens/forms/new_form_scope.dart';
import 'package:lightatech/Production/JobCreation/screens/forms/new_form.dart';
import 'package:lightatech/Features/Dashboard/screens/profile_screen.dart' as dashboard_profile;

// Intro
import 'package:lightatech/Features/Intro/screens/splash_screen.dart';
import 'package:lightatech/Features/Intro/screens/intro_screen.dart';
import 'package:lightatech/Features/Intro/screens/biometric_screen.dart';
import 'package:lightatech/Features/Intro/screens/fill_profile_screen.dart';
import 'package:lightatech/Features/Intro/screens/create_pin_screen.dart';
import 'package:lightatech/Features/Intro/auth/screens/lets_you_in_screen.dart';
import 'package:lightatech/Features/adminAccess/screens/admin_panel_screen.dart';
import 'package:lightatech/Features/adminAccess/screens/add_staff_screen.dart';
import 'package:lightatech/Features/adminAccess/screens/add_customer_screen.dart';


// Login
import 'package:lightatech/Login/LoginScreen.dart';
import 'package:lightatech/Login/Admin/Admin.dart';
import 'package:lightatech/core/session/session_manager.dart';

// Dashboard
import 'package:lightatech/Features/Dashboard/screens/dashboard_screen.dart';
import 'package:lightatech/Features/Dashboard/screens/home.dart';
import 'package:lightatech/Features/Dashboard/screens/job_summary_screen.dart';
import 'package:lightatech/Features/Dashboard/screens/customer_request_detail_screen.dart';
import 'package:lightatech/Features/Dashboard/screens/customer_requests_screen.dart';
import 'package:lightatech/Features/Dashboard/screens/pending_form_edit_screen.dart';

// Order
import '../customer/intro/viewmodel/order_detail_view.dart';

// Job Forms
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
import 'package:lightatech/Production/JobCreation/screens/forms/account/account_form_flow.dart';

// Map
import 'package:lightatech/Features/MapScreen/screens/map_screen.dart';
import 'package:lightatech/Features/MapScreen/screens/task_detail_page.dart';
import 'package:lightatech/Features/MapScreen/models/task.dart';

// Graph
import 'package:lightatech/Features/Graph/screens/graph_page.dart';
import 'package:lightatech/Features/Graph/widgets/graph_form.dart';
import 'package:lightatech/Features/Graph/screens/graph_tasks_page.dart';

// Target
import 'package:lightatech/Features/Target/screens/profile_screen.dart' as target_profile;

// Payment
import 'package:lightatech/Features/Payment/screens/paid_screen.dart';

// Firebase
import 'package:cloud_firestore/cloud_firestore.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

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
    initialLocation: '/',

    routes: [

      // AUTH
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: '/login',
        builder: (_, __) => const LoginScreen(),
      ),

      GoRoute(
        path: '/admin',
        builder: (_, __) => const Admin(),
      ),

      GoRoute(
        path: '/order-details',
        name: 'orderDetails',
        builder: (context, state) => OrderDetailScreen(),
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

      GoRoute(
        path: '/productivity',
        builder: (context, state) {
          return NewFormScope(
            form: NewFormState(),
            child: const AccountFormFlow(),
          );
        },
      ),

      // DASHBOARD SHELL
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return Home(
            child: child,
            location: state.uri.toString(),
          );
        },
        routes: [

          // FIXED DASHBOARD ROUTE
          GoRoute(
            path: '/dashboard',
            redirect: (context, state) {
              if (!SessionManager.isLoggedIn()) {
                return '/login';
              }
              return null;
            },
            builder: (context, state) {
              final dept = SessionManager.getDepartment()!;
              final email = SessionManager.getEmail()!;

              return DashboardScreen(
                department: dept,
                email: email,
              );
            },
          ),

          GoRoute(
            path: '/admin-panel',
            builder: (context, state) => const AdminPanelScreen(),
          ),

          GoRoute(
            path: '/add-staff',
            builder: (context, state) => const AddStaffScreen(),
          ),

          GoRoute(
            path: '/add-customer',
            builder: (context, state) => const AddCustomerScreen(),
          ),

          GoRoute(
            path: '/customer-requests',
            builder: (context, state) => const CustomerRequestsScreen(),
          ),

          GoRoute(
            path: '/customer-request-detail/:docId',
            builder: (context, state) {
              final docId = state.pathParameters['docId'] ?? '';
              return CustomerRequestDetailScreen(docId: docId);
            },
          ),

          GoRoute(
            path: '/pending-form-edit/:lpm',
            builder: (context, state) {
              final lpm = state.pathParameters['lpm'] ?? '';
              return PendingFormEditScreen(lpm: lpm);
            },
          ),

          GoRoute(
            path: '/job-summary/:lpm',
            builder: (context, state) =>
                JobSummaryScreen(lpm: state.pathParameters['lpm']!),
          ),

          GoRoute(
            path: '/map',
            name: AppRoutesName.MapScreen,
            builder: (context, state) => const MapScreen(title: 'Maps'),
          ),

          GoRoute(
            path: '/profile',
            builder: (context, state) => const dashboard_profile.ProfileScreen(),
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
            builder: (context, state) => const target_profile.ProfileScreen(),
          ),
        ],
      ),

      // JOB FORM SHELL
      // JOB FORM SHELL
      ShellRoute(
        builder: (context, state, child) {
          // 1. Try to get it from the query parameter
          String? dept = state.uri.queryParameters['department'];

          // 2. If it's null, auto-detect based on the URL path!
          if (dept == null) {
            final path = state.uri.path;
            if (path.contains('designer')) dept = 'designer';
            else if (path.contains('autobending')) dept = 'auto-bending';
            else if (path.contains('manualbending')) dept = 'manual-bending';
            else if (path.contains('laser')) dept = 'laser';
            else if (path.contains('emboss')) dept = 'emboss';
            else if (path.contains('rubber')) dept = 'rubber';
            else if (path.contains('account1')) dept = 'account1'; // 🟢 Catches the Account route!
            else if (path.contains('delivery')) dept = 'delivery';
            else dept = 'designer'; // Ultimate fallback
          }

          final lpm = state.uri.queryParameters['lpm'];
          final mode = state.uri.queryParameters['mode'];

          return NewForm(
            department: _normalizeDepartment(dept),
            lpm: lpm,
            mode: mode,
            child: child,
          );
        },
        routes: [

          GoRoute(
            path: '/jobform',
            redirect: (_, __) => '/jobform/designer-1?department=designer',
          ),

          GoRoute(path: '/jobform/designer-1', builder: (_, __) => const DesignerPage1()),
          GoRoute(path: '/jobform/designer-2', builder: (_, __) => const DesignerPage2()),
          GoRoute(path: '/jobform/designer-3', builder: (_, __) => const DesignerPage3()),
          GoRoute(path: '/jobform/designer-4', builder: (_, __) => const DesignerPage4()),
          GoRoute(path: '/jobform/designer-5', builder: (_, __) => const DesignerPage5()),
          GoRoute(path: '/jobform/designer-6', builder: (_, __) => const DesignerPage6()),

          GoRoute(path: '/jobform/autobending', builder: (_, __) => const AutoBendingPage()),
          GoRoute(path: '/jobform/manualbending', builder: (_, __) => const ManualBendingPage()),
          GoRoute(path: '/jobform/laser', builder: (_, __) => const LaserPage()),
          GoRoute(path: '/jobform/emboss', builder: (_, __) => const EmbossPage()),
          GoRoute(path: '/jobform/rubber', builder: (_, __) => const RubberPage()),
          GoRoute(path: '/jobform/account1', builder: (_, __) => const AccountFormFlow()),
          GoRoute(path: '/jobform/delivery', builder: (_, __) => const DeliveryPage()),
        ],
      ),

      // TASK
      GoRoute(
        path: '/task',
        builder: (context, state) {
          final task = state.extra as Task;

          return TaskDetailPage(
            task: task,
            onChanged: () async {
              if (task.id != null) {
                await FirebaseFirestore.instance
                    .collection('tasks')
                    .doc(task.id)
                    .update(task.toMap());
              }
            },
            onDelete: () async {
              if (task.id != null) {
                await FirebaseFirestore.instance
                    .collection('tasks')
                    .doc(task.id)
                    .delete();
              }
            },
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