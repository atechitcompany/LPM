import 'package:flutter/material.dart';

import '../models/analytics_model.dart';
import '../services/analytics_service.dart';
import '../widgets/analytics_summary_cards.dart';

class GraphPage extends StatefulWidget {
  const GraphPage({super.key});

  @override
  State<GraphPage> createState() => _GraphPageState();
}

class _GraphPageState extends State<GraphPage> {

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
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Analytics Dashboard",
        ),
      ),

      body: FutureBuilder<AnalyticsModel>(
        future: analyticsFuture,

        builder: (context, snapshot) {

          /// LOADING
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          /// ERROR
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

          /// EMPTY
          if (!snapshot.hasData) {
            return const Center(
              child: Text(
                "No analytics data found",
              ),
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

                  /// HEADER
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

                  /// KPI CARDS
                  AnalyticsSummaryCards(
                    totalJobs: analytics.totalJobs,
                    completedJobs: analytics.completedJobs,
                    pendingJobs: analytics.pendingJobs,
                    deliveredJobs: analytics.deliveredJobs,
                  ),

                  const SizedBox(height: 30),

                  /// EMPLOYEE ANALYTICS
                  const Text(
                    "Employee Productivity",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),

                    child: Column(
                      children: analytics.employeeJobs.entries.map((e) {

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),

                          child: Row(
                            children: [

                              Expanded(
                                child: Text(
                                  e.key,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),

                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),

                                child: Text(
                                  "${e.value} Jobs",
                                  style: TextStyle(
                                    color: Colors.blue.shade800,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// CUSTOMER ANALYTICS
                  const Text(
                    "Customer Orders",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),

                    child: Column(
                      children: analytics.customerOrders.entries.map((e) {

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),

                          child: Row(
                            children: [

                              Expanded(
                                child: Text(
                                  e.key,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),

                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),

                                child: Text(
                                  "${e.value} Orders",
                                  style: TextStyle(
                                    color: Colors.green.shade800,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// DEPARTMENT ANALYTICS
                  const Text(
                    "Department Workflow",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                        ),
                      ],
                    ),

                    child: Column(
                      children: analytics.departmentLoads.entries.map((e) {

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),

                          child: Row(
                            children: [

                              Expanded(
                                child: Text(
                                  e.key,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),

                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),

                                child: Text(
                                  "${e.value} Completed",
                                  style: TextStyle(
                                    color: Colors.orange.shade800,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

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