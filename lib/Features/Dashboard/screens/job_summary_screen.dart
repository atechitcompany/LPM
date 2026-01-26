import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class JobSummaryScreen extends StatelessWidget {
  final String lpm;
  const JobSummaryScreen({super.key, required this.lpm});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Job Summary")),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection("jobs").doc(lpm).get(),
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row("LPM No", lpm),
                _row("Party Name", designer["PartyName"]),
                _row("Particular Job", designer["ParticularJobName"]),
                _row("Delivery At", designer["DeliveryAt"]),
                _row("Order By", designer["Orderby"]),
                _row("Remark", designer["Remark"]),
                _row("Priority", designer["Priority"]),

                const SizedBox(height: 24),

                if (currentDepartment != "Completed")
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.push(
                          '/jobform',
                          extra: {
                            'department': currentDepartment,
                            'lpm': lpm,
                            'mode': 'edit',
                          },
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
            child: Text(value?.toString().trim().isNotEmpty == true
                ? value.toString()
                : "-"),
          ),
        ],
      ),
    );
  }
}
