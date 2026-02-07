import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../core/session/session_manager.dart';

class JobSummaryScreen extends StatelessWidget {
  final String lpm;
  const JobSummaryScreen({super.key, required this.lpm});

  String _prettyValue(dynamic value) {
    if (value == null) return "-";

    // Boolean formatting
    if (value is bool) {
      return value ? "Yes" : "No";
    }

    // List formatting
    if (value is List) {
      if (value.isEmpty) return "-";
      return value.join(", ");
    }

    // Map formatting (fallback)
    if (value is Map) {
      if (value.isEmpty) return "-";
      return value.entries
          .map((e) => "${e.key}: ${e.value}")
          .join(", ");
    }

    // String / number fallback
    final str = value.toString().trim();
    return str.isEmpty ? "-" : str;
  }


  static const Map<String, String> departmentEditRoute = {
    "Designer": "/jobform/designer-1",
    "AutoBending": "/jobform/autobending",
    "ManualBending": "/jobform/manualbending",
    "LaserCutting": "/jobform/laser",
    "Emboss": "/jobform/emboss",
    "Rubber": "/jobform/rubber",
    "Account": "/jobform/account1",
    "Delivery": "/jobform/delivery",
  };

  static const Map<String, String> departmentFirestoreKey = {
    "Designer": "designer",
    "AutoBending": "autoBending",
    "ManualBending": "manualBending",
    "LaserCutting": "laserCut",
    "Emboss": "emboss",
    "Rubber": "rubber",
    "Account": "account",
    "Delivery": "delivery",
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
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snap.data!.exists) {
              return const Center(child: Text("Job not found"));
            }

            final data = snap.data!.data() as Map<String, dynamic>;
            final dept = SessionManager.getDepartment();

            final deptKey = departmentFirestoreKey[dept];
            final Map<String, dynamic> summaryData =
            Map<String, dynamic>.from(
              data[deptKey]?["data"] ?? {},
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [

                  // ================= HEADER =================
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
                          Text(
                            "$dept Summary",
                            style: const TextStyle(
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

                  // ================= FORM SUMMARY =================
                  _sectionTitle("$dept Form Details"),
                  _card(
                    summaryData.entries
                        .map(
                          (e) => _row(
                        e.key,
                        _prettyValue(e.value),
                      ),
                    )
                        .toList(),
                  ),

                  const SizedBox(height: 24),

                  // ================= EDIT BUTTON =================
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final route = departmentEditRoute[dept];

                        debugPrint(
                            "EDIT CLICK → dept=$dept route=$route lpm=$lpm");

                        if (route == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("No form for $dept")),
                          );
                          return;
                        }

                        context.push("$route?lpm=$lpm&mode=edit");
                      },
                      child: const Text("Edit"),
                    ),
                  ),
                ],
              ),
            );
          }
      ),
    );
  }

  // ================= UI HELPERS =================

  Widget _sectionTitle(String t) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          t,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _row(String label, dynamic value) {
    final text = (value == null || value.toString().trim().isEmpty)
        ? "-"
        : value.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              text,
              style: TextStyle(
                color: text == "-" ? Colors.grey : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
