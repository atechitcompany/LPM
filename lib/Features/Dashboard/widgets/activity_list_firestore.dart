import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'activity_list.dart';
import 'package:go_router/go_router.dart';

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
  @override
  Widget build(BuildContext context) {
    if (!_isValidDepartment(widget.department)) {
      return const Center(child: Text("Invalid department"));
    }

    if (widget.department == "Designer") {
      return DefaultTabController(
        length: 4,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TabBar(
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey.shade500,
                    labelStyle: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 13),
                    unselectedLabelStyle: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 13),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorWeight: 2,
                    indicatorColor: const Color(0xFFF8D94B),
                    dividerColor: Colors.black,
                    dividerHeight: 0.8,
                    tabs: const [
                      Tab(text: "Pending"),
                      Tab(text: "Jobs"),
                      Tab(text: "Quotations"),
                      Tab(text: 'Quotation Pending'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // ── Pending tab ─────────────────────────────────────
                  // DesigningStatus == "Pending"
                  _KeepAliveTab(
                    child: _FirestoreTab(
                      department: widget.department,
                      searchText: widget.searchText,
                      isPending: true,
                    ),
                  ),
                  // ── Jobs tab ────────────────────────────────────────
                  // DesigningStatus == "Done"
                  _KeepAliveTab(
                    child: _FirestoreTab(
                      department: widget.department,
                      searchText: widget.searchText,
                      isPending: false,
                    ),
                  ),
                  // ── Quotations tab ──────────────────────────────────
                  // ── Quotations tab ──────────────────────────────────
                  _KeepAliveTab(
                    child: _QuotationsTab(searchText: widget.searchText),
                  ),
                  _KeepAliveTab(
                    child: _QuotationPendingTab(searchText: widget.searchText),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Other departments — jobs only
    return _FirestoreTab(
      department: widget.department,
      searchText: widget.searchText,
      isPending: false,
    );
  }

  bool _isValidDepartment(String dept) {
    return const [
      "Designer",
      "AutoBending",
      "ManualBending",
      "LaserCutting",
      "Emboss",
      "Rubber",
      "Account",
      "Delivery",
    ].contains(dept);
  }
}

// ── Empty Quotations placeholder ─────────────────────────────────────────────
class _EmptyQuotations extends StatelessWidget {
  const _EmptyQuotations();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.description_outlined,
              size: 56, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            "Quotations coming soon",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Keeps tab alive when switching ───────────────────────────────────────────
class _KeepAliveTab extends StatefulWidget {
  final Widget child;
  const _KeepAliveTab({required this.child});

  @override
  State<_KeepAliveTab> createState() => _KeepAliveTabState();
}

class _KeepAliveTabState extends State<_KeepAliveTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

// ── Single tab: Firestore stream ─────────────────────────────────────────────
class _FirestoreTab extends StatefulWidget {
  final String department;
  final String searchText;
  final bool isPending;

  const _FirestoreTab({
    required this.department,
    required this.searchText,
    required this.isPending,
  });

  @override
  State<_FirestoreTab> createState() => _FirestoreTabState();
}

class _FirestoreTabState extends State<_FirestoreTab> {
  Stream<QuerySnapshot>? _stream;
  final ScrollController _scrollController = ScrollController();
  final Set<String> _processedDocs = {};

  List<QueryDocumentSnapshot> _olderDocs = [];
  bool _isLoadingMore = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDoc;

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore || _lastDoc == null) return;

    setState(() => _isLoadingMore = true);

    Query query = FirebaseFirestore.instance
        .collection("jobs")
        .where("visibleTo", arrayContains: widget.department)
        .orderBy("updatedAt", descending: true)
        .startAfterDocument(_lastDoc!)
        .limit(20);

    final snap = await query.get();

    if (snap.docs.isNotEmpty) {
      _olderDocs.addAll(snap.docs);
      _lastDoc = snap.docs.last;
    } else {
      _hasMore = false;
    }

    setState(() => _isLoadingMore = false);
  }

  Future<void> _handleCustomerApproval(QueryDocumentSnapshot doc) async {
    debugPrint("✏️ WRITE TRIGGERED");
    final data = doc.data() as Map<String, dynamic>;

    final approvalStatus =
    (data["customerApprovalStatus"] ?? "").toString().toLowerCase();

    final visibleTo = List<String>.from(data["visibleTo"] ?? []);

    // ✅ ADD THIS LINE
    if (visibleTo.length > 1) return; // already processed

    if (approvalStatus == "approved" && visibleTo.length == 1) {
      await FirebaseFirestore.instance
          .collection("jobs")
          .doc(doc.id)
          .update({
        "visibleTo": [
          "Designer",
          "AutoBending",
          "ManualBending",
          "LaserCutting",
          "Rubber",
          "Emboss"
        ],
        "currentDepartment": "InProgress",
        "status": "approved",
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _setupStream();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_FirestoreTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.department != widget.department ||
        oldWidget.isPending != widget.isPending) {
      _setupStream();
    }
  }

  void _setupStream() {
    _processedDocs.clear();

    // ✅ ADD THESE 3 LINES
    _olderDocs.clear();
    _lastDoc = null;
    _hasMore = true;

    if (widget.department == "Designer" && widget.isPending) {
      _stream = FirebaseFirestore.instance
          .collection("jobs")
          .where("visibleTo", arrayContains: "Designer")
          .orderBy("updatedAt", descending: true)
          .limit(20).snapshots();
    } else if (widget.department == "Designer" && !widget.isPending) {
      // Jobs tab → Designing is done
      _stream = FirebaseFirestore.instance
          .collection("jobs")
          .where("visibleTo", arrayContains: "Designer")
          .where("designer.data.DesigningStatus", isEqualTo: "Done")
          .orderBy("updatedAt", descending: true)
          .limit(20).snapshots();
    } else {
      // All other departments
      _stream = FirebaseFirestore.instance
          .collection("jobs")
          .where("visibleTo", arrayContains: widget.department)
          .orderBy("updatedAt", descending: true)
          .limit(20).snapshots();
      }
  }

  @override
  Widget build(BuildContext context) {
    if (_stream == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: _stream,
      builder: (context, snapshot) {
        debugPrint("📡 STREAM TRIGGERED");
        if (snapshot.hasError) {
          debugPrint("❌ Stream error: ${snapshot.error}");
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            snapshot.data == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final latestDocs = List<QueryDocumentSnapshot>.from(snapshot.data?.docs ?? []);

// Set lastDoc for pagination
        if (latestDocs.isNotEmpty) {
          _lastDoc = latestDocs.last;
        }

// Merge latest + older
        final Map<String, QueryDocumentSnapshot> uniqueDocs = {};

        for (var d in latestDocs) {
          uniqueDocs[d.id] = d;
        }
        for (var d in _olderDocs) {
          uniqueDocs[d.id] = d;
        }

        final docs = uniqueDocs.values.toList();

        // Search filter
        final query = widget.searchText.trim().toLowerCase();

        // Note: _handleCustomerApproval is available but must be triggered
        // by a user action (not automatically) to avoid read-write loops.
        final filtered = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;

          final designer =
          (data["designer"]?["data"] ?? {}) as Map<String, dynamic>;

          final matchesSearch =
              doc.id.toLowerCase().contains(query) ||
                  (designer["PartyName"] ?? "").toString().toLowerCase().contains(query) ||
                  (designer["ParticularJobName"] ?? "").toString().toLowerCase().contains(query);

          if (query.isNotEmpty && !matchesSearch) return false;

          final designingStatus =
          (designer["DesigningStatus"] ?? "").toString().toLowerCase();

          final approvalStatus =
          (data["customerApprovalStatus"] ?? "").toString().toLowerCase();


          // ================= PENDING TAB =================
          if (widget.isPending) {
            // Show anything NOT fully completed

            if (designingStatus != "done") return true;

            if (approvalStatus == "pending") return true;

            if (approvalStatus == "changes") return true;

            return false;
          }

          // ================= JOBS TAB =================
          if (!widget.isPending) {
            // ❌ Hide waiting approval
            if (approvalStatus == "pending") return false;

            // ❌ Hide incomplete work
            if (designingStatus != "done") return false;

            // ✅ Everything completed OR changes fixed
            return true;
          }

          return true;
        }).toList();

        return ActivityList(
          docs: filtered,
          isPending: widget.isPending,
          isQuotation: false,
          hasMore: _hasMore,
          isLoadingMore: _isLoadingMore,
          scrollController: _scrollController,
        );
      },
    );
  }
}
class _QuotationsTab extends StatelessWidget {
  final String searchText;
  const _QuotationsTab({required this.searchText});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("quotations")
          .orderBy("createdAt", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final docs = snapshot.data?.docs ?? [];
        final query = searchText.trim().toLowerCase();

        final filtered = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          if (query.isEmpty) return true;
          return doc.id.toLowerCase().contains(query) ||
              (data["partyName"] ?? "").toString().toLowerCase().contains(query);
        }).toList();

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.description_outlined,
                    size: 56, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text(
                  "No quotations yet",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade400),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final doc = filtered[index];
            final data = doc.data() as Map<String, dynamic>;
            final designerData = (data["designer"]?["data"] ?? {}) as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                onTap: () => context.push('/quotation-detail/${doc.id}'), // ← ADD HERE
                title: Text(
                  doc.id,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14),
                ),
                subtitle: Text(
                  data["partyName"] ?? designerData["PartyName"] ?? "—",
                  style: TextStyle(
                      fontSize: 13, color: Colors.grey.shade600),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8D94B).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    (data["status"] ?? "pending").toString().toUpperCase(),
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
class _QuotationPendingTab extends StatelessWidget {
  final String searchText;
  const _QuotationPendingTab({required this.searchText});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("quotation_pending")
          .orderBy("createdAt", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final docs = snapshot.data?.docs ?? [];
        final query = searchText.trim().toLowerCase();

        final filtered = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          if (query.isEmpty) return true;
          return doc.id.toLowerCase().contains(query) ||
              (data["partyName"] ?? "").toString().toLowerCase().contains(query);
        }).toList();

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.hourglass_empty, size: 56, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                Text(
                  "No pending quotations",
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade400),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final doc = filtered[index];
            final data = doc.data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                onTap: () => context.push('/customer-quotation-detail/${doc.id}'),
                title: Text(
                  doc.id,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14),
                ),
                subtitle: Text(
                  data["partyName"] ?? "—",
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "PENDING",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}