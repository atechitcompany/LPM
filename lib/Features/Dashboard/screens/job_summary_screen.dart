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
    "LaserCutting": "/jobform/laser",
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
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snap.data!.exists) {
            return const Center(child: Text("Job not found"));
          }

          final data = snap.data!.data() as Map<String, dynamic>;

          final designer =
          Map<String, dynamic>.from(data["designer"]?["data"] ?? {});
          final auto =
          Map<String, dynamic>.from(data["autoBending"]?["data"] ?? {});

          final dept = SessionManager.getDepartment();

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

                // ================= DESIGNER SUMMARY =================

                if (dept == "Designer")
                  _card([
                    _row("Party Name", designer["PartyName"]),
                    _row("Particular Job Name", designer["ParticularJobName"]),
                    _row("Delivery At", designer["DeliveryAt"]),
                    _row("Order By", designer["Orderby"]),
                    _row("Priority", designer["Priority"]),
                    _row("Remark", designer["Remark"]),
                  ]),

                // ================= AUTOBENDING SUMMARY =================

                if (dept == "AutoBending") ...[
                  _sectionTitle("AutoBending Details"),
                  _card([
                    _row("Party Name", designer["PartyName"]),
                    _row("Delivery At", designer["DeliveryAt"]),
                    _row("Order By", designer["Orderby"]),
                    _row("Particular Job Name", designer["ParticularJobName"]),
                    _row("Priority", designer["Priority"]),
                    _row("LPM", lpm),
                    _row("AutoBending Status", auto["AutoBendingStatus"]),   // ✅ ADD
                    _row("AutoBending Created By", auto["AutoBendingCreatedBy"]),
                    _row("Auto Creasing", auto["AutoCreasing"] == true ? "Yes" : "No"),
                    _row("Auto Creasing Status", auto["AutoCreasingStatus"]),
                  ]),

                  const SizedBox(height: 12),

                ],

                const SizedBox(height: 24),

                // ================= EDIT BUTTON =================

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final dept = SessionManager.getDepartment();
                      final route = departmentEditRoute[dept];

                      debugPrint("EDIT CLICK → dept=$dept route=$route lpm=$lpm");

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
        },
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
