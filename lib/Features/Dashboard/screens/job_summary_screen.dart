import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

import '../../../core/session/session_manager.dart';

class JobSummaryScreen extends StatelessWidget {
  final String lpm;
  const JobSummaryScreen({super.key, required this.lpm});

  static const Map<String, String> departmentEditRoute = {
    "Designer": "/jobform/designer-1",
    "AutoBending": "/jobform/autobending",
    "ManualBending": "/jobform/manualbending",
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
          final entries = designer.entries.toList();


          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // HEADER CARD
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Job Summary",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Chip(
                          label: Text("LPM $lpm"),
                          backgroundColor: Colors.amber.shade100,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // FORM DATA CARD
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: entries
                          .map<Widget>((entry) =>
                          _prettyRow(entry.key, entry.value))
                          .toList(),
                    ),
                  ),
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

  Widget _prettyRow(String label, dynamic value) {
    final textValue =
    value?.toString().trim().isNotEmpty == true
        ? value.toString()
        : "-";
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              textValue,
              style: TextStyle(
                color: textValue == "-"
                    ? Colors.grey
                    : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
// Summary done
