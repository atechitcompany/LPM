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

    // ✅ FIRESTORE QUERIES — DO NOT MODIFY
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

    // ✅ FOR DESIGNER - Show 3 tabs: Jobs, Pending, Quotations
    if (widget.department == "Designer") {
      return DefaultTabController(
        length: 3,
        child: Column(
          children: [
            // ── Tab Bar ──────────────────────────────────────────────────
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
                  borderSide: BorderSide(
                    width: 3,
                    color: Color(0xFFF8D94B),
                  ),
                  insets: EdgeInsets.symmetric(horizontal: 12),
                ),
                tabs: const [
                  Tab(text: "Jobs"),
                  Tab(text: "Pending"),
                  Tab(text: "Quotations"),
                ],
              ),
            ),
            // ── Tab Content ──────────────────────────────────────────────
            Expanded(
              child: TabBarView(
                children: [
                  // ✅ JOBS / RECENT ACTIVITIES TAB
                  _buildRecentActivitiesSection(),
                  // ✅ PENDING TAB
                  _buildPendingSection(),
                  // ✅ QUOTATIONS TAB
                  _buildQuotationsSection(),
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

  // ─────────────────────────────────────────────────────────────────────────
  // ✅ PENDING SECTION — Only for Designer — LOGIC UNCHANGED
  // ─────────────────────────────────────────────────────────────────────────
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

  // ─────────────────────────────────────────────────────────────────────────
  // ✅ RECENT ACTIVITIES SECTION — LOGIC UNCHANGED
  // ─────────────────────────────────────────────────────────────────────────
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
          return bUpdated.compareTo(aUpdated);
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

  // ─────────────────────────────────────────────────────────────────────────
  // ✅ QUOTATIONS SECTION — reuses same streams, shown in 3rd tab
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildQuotationsSection() {
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
          return const Center(child: Text("No quotations"));
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
          return const Center(child: Text("No matching quotations"));
        }

        return _buildFormList(filteredDocs, isQuotation: true);
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ✅ COMMON LIST BUILDER — UI ONLY CHANGED, ALL LOGIC PRESERVED
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildFormList(
      List<QueryDocumentSnapshot> docs, {
        bool isPending = false,
        bool isQuotation = false,
      }) {
    return Container(
      color: Colors.white,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 6),
        itemCount: docs.length,
        itemBuilder: (context, index) {
          final data = docs[index].data() as Map<String, dynamic>;
          final designerData = data["designer"]?["data"] ?? {};
          final lpm = docs[index].id;

          // ✅ DATA FIELDS — UNCHANGED
          final name =
              designerData["name"] ?? designerData["PartyName"] ?? "No Name";
          final party =
              designerData["partyName"] ?? designerData["PartyName"] ?? "No Party";
          final job = designerData["particularJobName"] ??
              designerData["ParticularJobName"] ??
              "No Job";

          // Resolve status badge
          final String rawStatus = (data["status"] ?? "").toString();
          final _BadgeStyle badge = _resolveBadge(rawStatus, isPending);

          return InkWell(
            // ✅ NAVIGATION — UNCHANGED
            onTap: isPending
                ? () => context.push('/pending-form-edit/$lpm')
                : () => context.push('/job-summary/$lpm'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade100, width: 1),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Avatar icon ─────────────────────────────────────────
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_outline,
                      color: Colors.grey.shade400,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // ── Name + Description ──────────────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          name.toString(),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Color(0xFF1A1A1A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          party.toString(),
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // ── Status Badge ────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: badge.bgColor,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: badge.borderColor, width: 1),
                    ),
                    child: Text(
                      badge.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: badge.textColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // ── Call Button ─────────────────────────────────────────
                  _CircleButton(
                    color: const Color(0xFF2196F3),
                    child: const Icon(
                      Icons.phone,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 6),

                  // ── WhatsApp Button ─────────────────────────────────────
                  _CircleButton(
                    color: const Color(0xFF25D366),
                    child: Image.asset(
                      'assets/whatsapp-logo.png',
                      width: 16,
                      height: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ✅ HELPERS — UNCHANGED
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

  /// Maps Firestore status string → badge colours/label
  _BadgeStyle _resolveBadge(String rawStatus, bool isPending) {
    if (isPending) {
      return _BadgeStyle(
        label: 'Pending',
        textColor: const Color(0xFFFF9800),
        bgColor: const Color(0xFFFFF3E0),
        borderColor: const Color(0xFFFFCC80),
      );
    }
    switch (rawStatus.toLowerCase()) {
      case 'hot':
      case 'pending_designer_review':
        return _BadgeStyle(
          label: rawStatus.toLowerCase() == 'hot' ? 'Hot' : 'Pending',
          textColor: const Color(0xFFE53935),
          bgColor: const Color(0xFFFFEBEE),
          borderColor: const Color(0xFFEF9A9A),
        );
      case 'paid':
        return _BadgeStyle(
          label: 'Paid',
          textColor: const Color(0xFF2E7D32),
          bgColor: const Color(0xFFE8F5E9),
          borderColor: const Color(0xFFA5D6A7),
        );
      case 'cold':
        return _BadgeStyle(
          label: 'Cold',
          textColor: const Color(0xFF1565C0),
          bgColor: const Color(0xFFE3F2FD),
          borderColor: const Color(0xFF90CAF9),
        );
      case 'hold':
        return _BadgeStyle(
          label: 'Hold',
          textColor: const Color(0xFFE65100),
          bgColor: const Color(0xFFFFF3E0),
          borderColor: const Color(0xFFFFCC80),
        );
      case 'cancel':
      case 'cancelled':
        return _BadgeStyle(
          label: 'Cancel',
          textColor: const Color(0xFF616161),
          bgColor: const Color(0xFFF5F5F5),
          borderColor: const Color(0xFFBDBDBD),
        );
      default:
        return _BadgeStyle(
          label: 'Active',
          textColor: const Color(0xFF1565C0),
          bgColor: const Color(0xFFE3F2FD),
          borderColor: const Color(0xFF90CAF9),
        );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small UI helpers
// ─────────────────────────────────────────────────────────────────────────────

class _BadgeStyle {
  final String label;
  final Color textColor;
  final Color bgColor;
  final Color borderColor;

  const _BadgeStyle({
    required this.label,
    required this.textColor,
    required this.bgColor,
    required this.borderColor,
  });
}

class _CircleButton extends StatelessWidget {
  final Color color;
  final Widget child;

  const _CircleButton({required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(child: child),
    );
  }
}