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
        future: FirebaseFirestore.instance
            .collection("jobs")
            .doc(lpm)
            .get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final designer = data["designer"]?["data"] ?? {};
          final currentDepartment = data["currentDepartment"];

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                _row("Party", designer["PartyName"]),
                _row("Job", designer["ParticularJobName"]),
                _row("Delivery At", designer["DeliveryAt"]),
                _row("Priority", designer["Priority"]),

                const SizedBox(height: 24),

                if (currentDepartment != "Completed")
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final path =
                            '/jobform/${currentDepartment.toLowerCase()}?lpm=$lpm&mode=edit';

                        debugPrint('EDIT CLICK → $path');

                        context.push(path);
                      },

                      child: const Text("Edit"),
                    ),
                  )
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
        children: [
          Text("$label: ",
              style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value?.toString() ?? "-")),
        ],
      ),
    );
  }
}
