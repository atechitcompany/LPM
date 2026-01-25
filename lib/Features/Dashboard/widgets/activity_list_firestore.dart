import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:async/async.dart';

class ActivityListFirestore extends StatefulWidget {
  final String searchText;
  final String department;

  const ActivityListFirestore({
    super.key,
    required this.searchText,
    required this.department,
  });

  @override
  State<ActivityListFirestore> createState() =>
      _ActivityListFirestoreState();
}

class _ActivityListFirestoreState extends State<ActivityListFirestore> {
  Stream<QuerySnapshot>? _currentDeptStream;
  Stream<QuerySnapshot>? _submittedByMeStream;

  @override
  void initState() {
    super.initState();

    if (!_isValidDepartment(widget.department)) return;

    final deptKey = _deptKey(widget.department);

    _currentDeptStream = FirebaseFirestore.instance
        .collection("jobs")
        .where("currentDepartment", isEqualTo: widget.department)
        .snapshots();

    _submittedByMeStream = FirebaseFirestore.instance
        .collection("jobs")
        .where("$deptKey.submitted", isEqualTo: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isValidDepartment(widget.department)) {
      return const Center(child: Text("Invalid department"));
    }

    return StreamBuilder<List<QuerySnapshot>>(
      stream: StreamZip([
        _currentDeptStream!,
        _submittedByMeStream!,
      ]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final Map<String, QueryDocumentSnapshot> merged = {};

        for (final snap in snapshot.data!) {
          for (final doc in snap.docs) {
            merged[doc.id] = doc;
          }
        }

        final docs = merged.values.toList();

        if (docs.isEmpty) {
          return const Center(child: Text("No entries available"));
        }

        final query = widget.searchText.trim().toLowerCase();

        final filteredDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final designerData = data["designer"]?["data"] ?? {};

          final party =
          (designerData["PartyName"] ?? "").toString().toLowerCase();
          final job =
          (designerData["ParticularJobName"] ?? "").toString().toLowerCase();

          if (query.isEmpty) return true;
          return party.contains(query) || job.contains(query);
        }).toList();

        if (filteredDocs.isEmpty) {
          return const Center(child: Text("No matching entries"));
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final data =
            filteredDocs[index].data() as Map<String, dynamic>;
            final designerData = data["designer"]?["data"] ?? {};

            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                onTap: () {
                  context.push('/job-summary/${filteredDocs[index].id}');
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.grey.shade200,
                        child: const Icon(
                          Icons.assignment_outlined,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (designerData["PartyName"] ??
                                  "No Party Name")
                                  .toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (designerData["ParticularJobName"] ??
                                  "No Particular Job")
                                  .toString(),
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ---------------- HELPERS ----------------

  bool _isValidDepartment(String dept) {
    return const [
      "Designer",
      "AutoBending",
      "ManualBending",
      "Lasercut",
      "Emboss",
      "Rubber",
      "Account",
      "Delivery",
    ].contains(dept);
  }

  String _deptKey(String dept) {
    switch (dept) {
      case "Designer":
        return "designer";
      case "AutoBending":
        return "autoBending";
      case "ManualBending":
        return "manualBending";
      case "Lasercut":
        return "laserCut";
      case "Emboss":
        return "emboss";
      case "Rubber":
        return "rubber";
      case "Account":
        return "account";
      case "Delivery":
        return "delivery";
      default:
        return "";
    }
  }
}
