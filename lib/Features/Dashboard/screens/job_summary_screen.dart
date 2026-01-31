import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import '../../../core/session/session_manager.dart';

class JobSummaryScreen extends StatelessWidget {
  final String lpm;
  const JobSummaryScreen({super.key, required this.lpm});

  static const Map<String, String> departmentEditRoute = {
    "Designer": "/jobform/designer-1",
    "AutoBending": "/jobform/auto-bending",
    "ManualBending": "/jobform/manual-bending",
    "Lasercut": "/jobform/laser",
    "Emboss": "/jobform/emboss",
    "Rubber": "/jobform/rubber",
    "Account": "/jobform/account1",
    "Delivery": "/jobform/delivery",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Job Summary")),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection("jobs")
            .doc(lpm)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Job not found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final designer = data["designer"]?["data"] ?? {};
          final currentDepartment =
          (data["currentDepartment"] ?? "").toString();

          /// Fields to show
          final fields = {
            "LPM No": lpm,
            "Party Name": designer["PartyName"],
            "Particular Job": designer["ParticularJobName"],
            "Delivery At": designer["DeliveryAt"],
            "Order By": designer["Orderby"],
            "Remark": designer["Remark"],
            "Priority": designer["Priority"],
            "Size": designer["Size"],
            "Ups": designer["Ups"],
            "Ply Type": designer["PlyType"],
            "Blade": designer["Blade"],
            "Creasing": designer["Creasing"],
          };

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...fields.entries.map(
                      (e) => _row(e.key, e.value),
                ),

                const SizedBox(height: 24),

                if (currentDepartment != "Completed")
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final loggedInDept =
                        SessionManager.getDepartment();

                        if (loggedInDept == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "Session expired. Please login again.")),
                          );
                          return;
                        }

                        final route =
                        departmentEditRoute[loggedInDept];

                        if (route == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    "No edit form for $loggedInDept")),
                          );
                          return;
                        }

                        context.push(
                          "$route?lpm=$lpm&mode=edit",
                        );
                      },
                      child: const Text("Edit"),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _row(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value?.toString().trim().isNotEmpty == true
                  ? value.toString()
                  : "-",
            ),
          ),
        ],
      ),
    );
  }
}
