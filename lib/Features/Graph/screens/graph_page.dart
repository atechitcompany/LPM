import 'package:flutter/material.dart';

import '../models/analytics_model.dart';
import '../services/analytics_service.dart';
import '../widgets/analytics_summary_cards.dart';
import '../widgets/employee_productivity_chart.dart';
import '../widgets/top_customers_chart.dart';
import '../widgets/analytics_filter_bar.dart';
import '../widgets/department_status_chart.dart';
import 'package:lightatech/Features/Dashboard/screens/sidebar_menu.dart';

class GraphPage extends StatefulWidget {
  const GraphPage({super.key});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {
  String selectedGraph = "Employee Productivity";

  final List<String> graphTypes = [
    "Employee Productivity",
    "Top Customers",
    "Department Workflow",
  ];

  final AnalyticsService _analyticsService = AnalyticsService();

  late Future<AnalyticsModel> analyticsFuture;

  @override
  void initState() {
    super.initState();
    analyticsFuture = _analyticsService.fetchAnalytics();
  }

  Future<void> _refreshAnalytics() async {
    setState(() {
      analyticsFuture = _analyticsService.fetchAnalytics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const SidebarMenu(),
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        elevation: 0,
        title: const Text("Analytics Dashboard"),
      ),

      body: FutureBuilder<AnalyticsModel>(
        future: analyticsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  "Error:\n${snapshot.error}",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text("No analytics data found"),
            );
          }

          final analytics = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refreshAnalytics,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Production Analytics",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Live factory workflow overview",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),

                  const SizedBox(height: 24),

                  AnalyticsFilterBar(
                    selectedGraph: selectedGraph,
                    graphTypes: graphTypes,
                    onGraphChanged: (value) {
                      if (value == null) return;

                      setState(() {
                        selectedGraph = value;
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  AnalyticsSummaryCards(
                    totalJobs: analytics.totalJobs,
                    completedJobs: analytics.completedJobs,
                    pendingJobs: analytics.pendingJobs,
                    deliveredJobs: analytics.deliveredJobs,
                  ),

                  const SizedBox(height: 24),

                  if (selectedGraph == "Employee Productivity") ...[
                    EmployeeProductivityChart(
                      employeeData: analytics.employeeJobs,
                    ),
                  ],

                  if (selectedGraph == "Top Customers") ...[
                    TopCustomersChart(
                      customerData: analytics.customerOrders,
                    ),
                  ],

                  if (selectedGraph == "Department Workflow") ...[
                    DepartmentStatusChart(
                      departmentData: analytics.departmentLoads,
                    ),
                  ],

                  const SizedBox(height: 50),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}