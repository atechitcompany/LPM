class AnalyticsModel {
  final int totalJobs;
  final int completedJobs;
  final int pendingJobs;
  final int deliveredJobs;

  final Map<String, int> employeeJobs;
  final Map<String, int> customerOrders;
  final Map<String, int> departmentLoads;
  final Map<String, int> statusDistribution;

  AnalyticsModel({
    required this.totalJobs,
    required this.completedJobs,
    required this.pendingJobs,
    required this.deliveredJobs,
    required this.employeeJobs,
    required this.customerOrders,
    required this.departmentLoads,
    required this.statusDistribution,
  });
}