import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'activity_list.dart';

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
  // _jobsStream   → designer.submitted == true  (Jobs tab)
  // _pendingStream → status == "pending_designer_review"  (Pending tab)
  Stream<QuerySnapshot>? _jobsStream;
  Stream<QuerySnapshot>? _pendingStream;

  @override
  void initState() {
    super.initState();

    debugPrint("🏢 ActivityListFirestore department = '${widget.department}'");

    if (!_isValidDepartment(widget.department)) {
      debugPrint("❌ Invalid department: ${widget.department}");
      return;
    }

    final deptKey = _deptKey(widget.department);

    // ── Jobs: only where designer has submitted ───────────────────────────
    _jobsStream = FirebaseFirestore.instance
        .collection("jobs")
        .where("$deptKey.submitted", isEqualTo: true)
        .snapshots();

    // ── Pending: customer accepted, designer not yet reviewed ─────────────
    if (widget.department == "Designer") {
      _pendingStream = FirebaseFirestore.instance
          .collection("jobs")
          .where("status", isEqualTo: "pending_designer_review")
          .snapshots();

      debugPrint("✅ _pendingStream initialised");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isValidDepartment(widget.department)) {
      return const Center(child: Text("Invalid department"));
    }

    if (widget.department == "Designer") {
      return DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: TabBar(
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey.shade500,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                indicator: const UnderlineTabIndicator(
                  borderSide: BorderSide(width: 3, color: Color(0xFFF8D94B)),
                  insets: EdgeInsets.symmetric(horizontal: 12),
                ),
                tabs: const [
                  Tab(text: "Jobs"),
                  Tab(text: "Pending"),
                  Tab(text: "Quotations"),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildJobsSection(),
                  _buildPendingSection(),
                  _buildQuotationsSection(),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return _buildJobsSection();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // JOBS TAB — designer.submitted == true, sorted by updatedAt desc
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildJobsSection() {
    if (_jobsStream == null) {
      return const Center(
          child: Text("Stream not ready",
              style: TextStyle(color: Colors.grey)));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _jobsStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint("❌ _jobsStream error: ${snapshot.error}");
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var docs = snapshot.data!.docs;
        debugPrint("📋 Jobs tab: ${docs.length} docs");

        // Sort by updatedAt descending
        docs.sort((a, b) {
          final aT = (a.data() as Map<String, dynamic>)["updatedAt"]
          as Timestamp?;
          final bT = (b.data() as Map<String, dynamic>)["updatedAt"]
          as Timestamp?;
          if (aT == null || bT == null) return 0;
          return bT.compareTo(aT);
        });

        if (docs.isEmpty) {
          return const Center(
              child: Text("No jobs yet",
                  style: TextStyle(fontSize: 16, color: Colors.grey)));
        }

        final query = widget.searchText.trim().toLowerCase();
        final filtered = docs.where((doc) {
          final d = ((doc.data() as Map<String, dynamic>)["designer"]
          ?["data"]) ??
              {};
          final party =
          (d["partyName"] ?? d["PartyName"] ?? "").toString().toLowerCase();
          final job =
          (d["particularJobName"] ?? d["ParticularJobName"] ?? "")
              .toString()
              .toLowerCase();
          if (query.isEmpty) return true;
          return party.contains(query) || job.contains(query);
        }).toList();

        if (filtered.isEmpty) {
          return const Center(child: Text("No matching jobs"));
        }

        return ActivityList(
          docs: filtered,
          isPending: false,
          isQuotation: false,
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PENDING TAB — status == "pending_designer_review"
  // Sorted by acceptedAt descending → newest accepted form on top
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPendingSection() {
    if (_pendingStream == null) {
      debugPrint("⚠️ _pendingStream is null");
      return const Center(
          child: Text("Pending stream not ready",
              style: TextStyle(color: Colors.grey)));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _pendingStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint("❌ _pendingStream error: ${snapshot.error}");
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var docs = snapshot.data!.docs;
        debugPrint("⏳ Pending tab: ${docs.length} docs");

        // ✅ Sort by acceptedAt descending — newest accepted form on top
        docs.sort((a, b) {
          final aT = (a.data() as Map<String, dynamic>)["acceptedAt"]
          as Timestamp?;
          final bT = (b.data() as Map<String, dynamic>)["acceptedAt"]
          as Timestamp?;
          if (aT == null || bT == null) return 0;
          return bT.compareTo(aT); // descending = newest first
        });

        if (docs.isEmpty) {
          return const Center(
              child: Text("No pending forms",
                  style: TextStyle(fontSize: 16, color: Colors.grey)));
        }

        final query = widget.searchText.trim().toLowerCase();
        final filtered = docs.where((doc) {
          final d = ((doc.data() as Map<String, dynamic>)["designer"]
          ?["data"]) ??
              {};
          // customer_request_detail_screen writes lowercase keys
          final party = (d["partyName"] ?? "").toString().toLowerCase();
          final job =
          (d["particularJobName"] ?? "").toString().toLowerCase();
          if (query.isEmpty) return true;
          return party.contains(query) || job.contains(query);
        }).toList();

        if (filtered.isEmpty) {
          return const Center(child: Text("No matching pending forms"));
        }

        return ActivityList(
          docs: filtered,
          isPending: true,
          isQuotation: false,
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // QUOTATIONS TAB
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildQuotationsSection() {
    if (_jobsStream == null) {
      return const Center(
          child: Text("Stream not ready",
              style: TextStyle(color: Colors.grey)));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _jobsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(
              child: Text("No quotations",
                  style: TextStyle(fontSize: 16, color: Colors.grey)));
        }

        final query = widget.searchText.trim().toLowerCase();
        final filtered = docs.where((doc) {
          final d = ((doc.data() as Map<String, dynamic>)["designer"]
          ?["data"]) ??
              {};
          final party =
          (d["partyName"] ?? d["PartyName"] ?? "").toString().toLowerCase();
          final job =
          (d["particularJobName"] ?? d["ParticularJobName"] ?? "")
              .toString()
              .toLowerCase();
          if (query.isEmpty) return true;
          return party.contains(query) || job.contains(query);
        }).toList();

        if (filtered.isEmpty) {
          return const Center(child: Text("No matching quotations"));
        }

        return ActivityList(
          docs: filtered,
          isPending: false,
          isQuotation: true,
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────────────────
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
      case "Designer":      return "designer";
      case "AutoBending":   return "autoBending";
      case "ManualBending": return "manualBending";
      case "Lasercut":      return "laserCut";
      case "Emboss":        return "emboss";
      case "Rubber":        return "rubber";
      case "Account":       return "account";
      case "Delivery":      return "delivery";
      default:              return "";
    }
  }
}