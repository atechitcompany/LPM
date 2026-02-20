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
  State<ActivityListFirestore> createState() => _ActivityListFirestoreState();
}

class _ActivityListFirestoreState extends State<ActivityListFirestore> {
  Stream<QuerySnapshot>? _currentDeptStream;
  Stream<QuerySnapshot>? _submittedByMeStream;
  Stream<QuerySnapshot>? _pendingDesignerStream;

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

    // ✅ ONLY FOR DESIGNER - Pending forms (accepted but not yet filled)
    if (widget.department == "Designer") {
      _pendingDesignerStream = FirebaseFirestore.instance
          .collection("jobs")
          .where("status", isEqualTo: "pending_designer_review")
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isValidDepartment(widget.department)) {
      return const Center(child: Text("Invalid department"));
    }

    // ✅ FOR DESIGNER - Show 2 tabs only
    if (widget.department == "Designer") {
      return DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // Tab bar
            Container(
              color: Colors.white,
              child: TabBar(
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Colors.black,
                tabs: const [
                  Tab(text: "Recent Activities"),
                  Tab(text: "Pending"),
                ],
              ),
            ),
            // Tab content
            Expanded(
              child: TabBarView(
                children: [
                  // ✅ RECENT ACTIVITIES TAB (FIRST/LEFT)
                  _buildRecentActivitiesSection(),
                  // ✅ PENDING TAB (SECOND/RIGHT)
                  _buildPendingSection(),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // ✅ FOR OTHER DEPARTMENTS - Show only recent activities
    return _buildRecentActivitiesSection();
  }

  // ✅ PENDING SECTION - Only for Designer
  Widget _buildPendingSection() {
    return StreamBuilder<QuerySnapshot>(
      stream: _pendingDesignerStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(
            child: Text(
              "No pending forms",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }

        final query = widget.searchText.trim().toLowerCase();
        final filteredDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final designerData = data["designer"]?["data"] ?? {};
          final partyName =
          (designerData["partyName"] ?? "").toString().toLowerCase();
          final jobName = (designerData["particularJobName"] ?? "")
              .toString()
              .toLowerCase();
          if (query.isEmpty) return true;
          return partyName.contains(query) || jobName.contains(query);
        }).toList();

        if (filteredDocs.isEmpty) {
          return const Center(child: Text("No matching pending forms"));
        }

        return _buildFormList(filteredDocs, isPending: true);
      },
    );
  }

  // ✅ RECENT ACTIVITIES SECTION
  Widget _buildRecentActivitiesSection() {
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

        // ✅ SORT BY updatedAt DESCENDING (newest first)
        docs.sort((a, b) {
          final aData = a.data() as Map<String, dynamic>;
          final bData = b.data() as Map<String, dynamic>;

          final aUpdated = aData["updatedAt"] as Timestamp?;
          final bUpdated = bData["updatedAt"] as Timestamp?;

          if (aUpdated == null || bUpdated == null) return 0;
          return bUpdated.compareTo(aUpdated); // descending (newest first)
        });

        if (docs.isEmpty) {
          return const Center(child: Text("No recent activities"));
        }

        final query = widget.searchText.trim().toLowerCase();

        final filteredDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final designerData = data["designer"]?["data"] ?? {};

          final party =
          (designerData["PartyName"] ?? "").toString().toLowerCase();
          final job = (designerData["ParticularJobName"] ?? "")
              .toString()
              .toLowerCase();

          if (query.isEmpty) return true;
          return party.contains(query) || job.contains(query);
        }).toList();

        if (filteredDocs.isEmpty) {
          return const Center(child: Text("No matching activities"));
        }

        return _buildFormList(filteredDocs);
      },
    );
  }

  // ✅ COMMON LIST BUILDER
  Widget _buildFormList(List<QueryDocumentSnapshot> docs,
      {bool isPending = false}) {
    return Container(
      color: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: docs.length,
        itemBuilder: (context, index) {
          final data = docs[index].data() as Map<String, dynamic>;
          final designerData = data["designer"]?["data"] ?? {};
          final lpm = docs[index].id;

          final name = designerData["name"] ?? designerData["PartyName"] ?? "No Name";
          final party = designerData["partyName"] ?? designerData["PartyName"] ?? "No Party";
          final job = designerData["particularJobName"] ??
              designerData["ParticularJobName"] ??
              "No Job";

          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: InkWell(
              onTap: isPending
                  ? () {
                // Navigate to pending form edit screen
                context.push('/pending-form-edit/$lpm');
              }
                  : () {
                // Navigate to job summary
                context.push('/job-summary/$lpm');
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isPending
                        ? Colors.orange.shade300
                        : Colors.grey.shade200,
                    width: isPending ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: isPending
                          ? Colors.orange.shade100
                          : Colors.grey.shade200,
                      child: Icon(
                        isPending
                            ? Icons.pending_actions
                            : Icons.assignment_outlined,
                        color: isPending
                            ? Colors.orange
                            : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "$party • $job",
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
                    const SizedBox(width: 8),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isPending
                            ? Colors.orange.shade100
                            : Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isPending
                            ? "Pending"
                            : "Active",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isPending
                              ? Colors.orange
                              : Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ✅ HELPERS
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