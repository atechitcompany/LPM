import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/analytics_model.dart';

class AnalyticsService {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<AnalyticsModel> fetchAnalytics() async {

    final snapshot =
    await _firestore.collection("jobs").get();

    int totalJobs = 0;
    int completedJobs = 0;
    int pendingJobs = 0;
    int deliveredJobs = 0;

    Map<String, int> employeeJobs = {};
    Map<String, int> customerOrders = {};
    Map<String, int> departmentLoads = {};
    Map<String, int> statusDistribution = {};

    for (final doc in snapshot.docs) {

      final data = doc.data();

      totalJobs++;

      /// ==============================
      /// NESTED COLLECTION DATA
      /// ==============================

      final designer =
      Map<String, dynamic>.from(
        data["designer"]?["data"] ?? {},
      );

      final autoBending =
      Map<String, dynamic>.from(
        data["autoBending"]?["data"] ?? {},
      );

      final laserCutting =
      Map<String, dynamic>.from(
        data["laserCutting"]?["data"] ?? {},
      );

      final account =
      Map<String, dynamic>.from(
        data["account"]?["data"] ?? {},
      );

      final delivery =
      Map<String, dynamic>.from(
        data["delivery"]?["data"] ?? {},
      );

      /// ==============================
      /// JOB STATUS
      /// ==============================

      final deliveryStatus =
      (delivery["DeliveryStatus"] ?? "")
          .toString()
          .toLowerCase();

      final laserStatus =
      (laserCutting["LaserCuttingStatus"] ?? "")
          .toString()
          .toLowerCase();

      if (laserStatus == "done") {
        completedJobs++;
      } else {
        pendingJobs++;
      }

      if (deliveryStatus == "done") {
        deliveredJobs++;
      }

      /// ==============================
      /// DESIGNER EMPLOYEE ANALYTICS
      /// ==============================

      final designerName =
      (designer["DesignerCreatedBy"] ?? "")
          .toString()
          .trim();

      if (designerName.isNotEmpty) {

        employeeJobs[designerName] =
            (employeeJobs[designerName] ?? 0) + 1;
      }

      /// ==============================
      /// CUSTOMER ANALYTICS
      /// ==============================

      final customer =
      (designer["PartyName"] ?? "")
          .toString()
          .trim();

      if (customer.isNotEmpty) {

        customerOrders[customer] =
            (customerOrders[customer] ?? 0) + 1;
      }

      /// ==============================
      /// DEPARTMENT ANALYTICS
      /// ==============================

      final autoStatus =
      (autoBending["AutoBendingStatus"] ?? "")
          .toString()
          .toLowerCase();

      if (autoStatus == "done") {

        departmentLoads["Auto Bending"] =
            (departmentLoads["Auto Bending"] ?? 0) + 1;
      }

      if (laserStatus == "done") {

        departmentLoads["Laser Cutting"] =
            (departmentLoads["Laser Cutting"] ?? 0) + 1;
      }

      final accountCreated =
      (account["AccountsCreatedBy"] ?? "")
          .toString()
          .trim();

      if (accountCreated.isNotEmpty) {

        departmentLoads["Accounts"] =
            (departmentLoads["Accounts"] ?? 0) + 1;
      }

      if (deliveryStatus == "done") {

        departmentLoads["Delivery"] =
            (departmentLoads["Delivery"] ?? 0) + 1;
      }

      /// ==============================
      /// STATUS DISTRIBUTION
      /// ==============================

      if (laserStatus == "done") {

        statusDistribution["Completed"] =
            (statusDistribution["Completed"] ?? 0) + 1;

      } else {

        statusDistribution["Pending"] =
            (statusDistribution["Pending"] ?? 0) + 1;
      }

      if (deliveryStatus == "done") {

        statusDistribution["Delivered"] =
            (statusDistribution["Delivered"] ?? 0) + 1;
      }
    }

    /// SORT EMPLOYEES

    final sortedEmployees =
    Map.fromEntries(
      employeeJobs.entries.toList()
        ..sort(
              (a, b) =>
              b.value.compareTo(a.value),
        ),
    );

    /// SORT CUSTOMERS

    final sortedCustomers =
    Map.fromEntries(
      customerOrders.entries.toList()
        ..sort(
              (a, b) =>
              b.value.compareTo(a.value),
        ),
    );

    return AnalyticsModel(
      totalJobs: totalJobs,
      completedJobs: completedJobs,
      pendingJobs: pendingJobs,
      deliveredJobs: deliveredJobs,
      employeeJobs: sortedEmployees,
      customerOrders: sortedCustomers,
      departmentLoads: departmentLoads,
      statusDistribution: statusDistribution,
    );
  }
}