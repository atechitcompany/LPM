import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../core/session/session_manager.dart';
import 'dart:convert';

class JobSummaryScreen extends StatelessWidget {
  final String lpm;
  const JobSummaryScreen({super.key, required this.lpm});

  static const Map<String, String> departmentEditRoute = {
    "Designer": "/jobform/designer-1",
    "AutoBending": "/jobform/autobending",
    "ManualBending": "/jobform/manualbending",
    "LaserCutting": "/jobform/laser",
    "Rubber": "/jobform/rubber",
    "Emboss": "/jobform/emboss",
  };

  static const Map<String, String> departmentFirestoreKey = {
    "Designer": "designer",
    "AutoBending": "autoBending",
    "ManualBending": "manualBending",
    "LaserCutting": "laserCutting",
    "Rubber": "rubber",
    "Emboss": "emboss",
  };

  final List<String> pipeline = const [
    "Designer",
    "AutoBending",
    "ManualBending",
    "LaserCutting",
    "Rubber",
    "Emboss",
  ];

  static const Map<String, String> pipelineLabels = {
    "Designer": "Design",
    "AutoBending": "Auto",
    "ManualBending": "Manual",
    "LaserCutting": "Laser",
    "Rubber": "Rubber",
    "Emboss": "Emboss",
  };



  String _prettyValue(dynamic value) {
    if (value == null) return "-";
    if (value is bool) return value ? "Yes" : "No";
    if (value is List) return value.isEmpty ? "-" : value.join(", ");
    final str = value.toString().trim();
    return str.isEmpty ? "-" : str;
  }

  @override
  Widget build(BuildContext context) {
    final currentDept = SessionManager.getDepartment() ?? "";

    return Scaffold(
      appBar: AppBar(title: const Text("Job Summary")),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow,
        child: const Icon(Icons.edit, color: Colors.black),
        onPressed: () {
          final route = departmentEditRoute[currentDept];

          if (route == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("No form for $currentDept")),
            );
            return;
          }

          context.push("$route?lpm=$lpm&mode=edit");
        },
      ),

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
          final currentDepartment = data["currentDepartment"] ?? "Designer";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [

                /// ================= HEADER =================
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Designer Details",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(lpm),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                /// ================= PIPELINE =================
                _buildPipeline(currentDepartment),

                const SizedBox(height: 20),

                /// ================= ALL FORM DATA =================
                ...pipeline.map((dept) {
                  final key = departmentFirestoreKey[dept];
                  final sectionData =
                  Map<String, dynamic>.from(data[key]?["data"] ?? {});

                  if (sectionData.isEmpty) return const SizedBox();

                  return Column(
                    children: [
                      _sectionTitle("$dept Details"),
                      _infoSection(sectionData),
                      const SizedBox(height: 16),
                    ],
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  /// ================= PIPELINE UI =================
  // ================= PIPELINE =================
  Widget _buildPipeline(String currentDept) {
    int currentIndex = pipeline.indexOf(currentDept);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "LIVE JOB STATUS",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(pipeline.length, (index) {
              final step = pipeline[index];

              bool isDone = index < currentIndex;
              bool isCurrent = index == currentIndex;

              Color color = Colors.grey.shade400;
              IconData icon = Icons.circle;

              if (isDone) {
                color = Colors.green;
                icon = Icons.check;
              } else if (isCurrent) {
                color = Colors.orange;
                icon = Icons.sync;
              }

              return Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        if (index != 0)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: index <= currentIndex
                                  ? Colors.green
                                  : Colors.grey.shade300,
                            ),
                          ),
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: color,
                          child: Icon(icon, color: Colors.white, size: 16),
                        ),
                        if (index != pipeline.length - 1)
                          Expanded(
                            child: Container(
                              height: 2,
                              color: index < currentIndex
                                  ? Colors.green
                                  : Colors.grey.shade300,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      pipelineLabels[step] ?? step,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: isCurrent
                            ? Colors.orange
                            : isDone
                            ? Colors.green
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// ================= UI HELPERS =================

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

  Widget _infoSection(Map<String, dynamic> data) {
    if (data.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "INFORMATION",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 12),

        ...data.entries.map((e) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        e.key,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Text(
                        _prettyValue(e.value),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 13,
                          color: _prettyValue(e.value) == "Not Provided"
                              ? Colors.grey
                              : Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.grey.shade300, height: 1),
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _row(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            flex: 6,
            child: Text(value.toString()),
          ),
        ],
      ),
    );
  }
}