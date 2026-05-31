import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'activity_list.dart';
import 'package:go_router/go_router.dart';
import 'package:lightatech/common/utils/date_grouping_util.dart';

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
    if (widget.department == "Account") {
      return DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: TabBar(
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey.shade500,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorWeight: 2,
                indicatorColor: const Color(0xFFF8D94B),
                dividerColor: Colors.black,
                dividerHeight: 0.8,
                tabs: const [
                  Tab(text: "Jobs"),
                  Tab(text: "Quotations"),
                  Tab(text: "Quotation Pending"),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _KeepAliveTab(child: _FirestoreTab(
                    department: widget.department,
                    searchText: widget.searchText,
                    isPending: false,
                  )),
                  _KeepAliveTab(child: _QuotationsTab(searchText: widget.searchText)),
                  _KeepAliveTab(child: _QuotationPendingTab(searchText: widget.searchText)),
                ],
              ),
            ),
          ],
        ),
      );
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
                    labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
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
                  _KeepAliveTab(child: _FirestoreTab(department: widget.department, searchText: widget.searchText, isPending: true)),
                  _KeepAliveTab(child: _FirestoreTab(department: widget.department, searchText: widget.searchText, isPending: false)),
                  _KeepAliveTab(child: _QuotationsTab(searchText: widget.searchText)),
                  _KeepAliveTab(child: _QuotationPendingTab(searchText: widget.searchText)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (widget.department == "Delivery") {
      return DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // --- BEGIN DELIVERY DASHBOARD TABS (PENDING/COMPLETED) ---
            Container(
              color: Colors.white,
              child: TabBar(
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey.shade500,
                labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorWeight: 2,
                indicatorColor: const Color(0xFFF8D94B),
                dividerColor: Colors.black,
                dividerHeight: 0.8,
                tabs: const [
                  Tab(text: "PENDING"),
                  Tab(text: "Completed"),
                ],
              ),
            ),
            // --- END DELIVERY DASHBOARD TABS (PENDING/COMPLETED) ---
            Expanded(
              child: TabBarView(
                children: [
                  _KeepAliveTab(child: _FirestoreTab(department: widget.department, searchText: widget.searchText, isPending: true)),
                  _KeepAliveTab(child: _FirestoreTab(department: widget.department, searchText: widget.searchText, isPending: false)),
                ],
              ),
            ),
          ],
        ),
      );
    }

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
      "Lasercut",
      "Emboss",
      "Rubber",
      "Account",
      "Delivery",
    ].contains(dept);
  }
}

// ── Keeps tab alive when switching ───────────────────────────────────────────
class _KeepAliveTab extends StatefulWidget {
  final Widget child;
  const _KeepAliveTab({required this.child});

  @override
  State<_KeepAliveTab> createState() => _KeepAliveTabState();
}

class _KeepAliveTabState extends State<_KeepAliveTab> with AutomaticKeepAliveClientMixin {
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

  const _FirestoreTab({required this.department, required this.searchText, required this.isPending});

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

    String queryDept = widget.department == "Lasercut" ? "LaserCutting" : widget.department;
    Query query = FirebaseFirestore.instance
        .collection("jobs")
        .where("visibleTo", arrayContains: queryDept)
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
    final data = doc.data() as Map<String, dynamic>;
    final approvalStatus = (data["customerApprovalStatus"] ?? "").toString().toLowerCase();
    final visibleTo = List<String>.from(data["visibleTo"] ?? []);
    if (visibleTo.length > 1) return;
    if (approvalStatus == "approved" && visibleTo.length == 1) {
      await FirebaseFirestore.instance.collection("jobs").doc(doc.id).update({
        "visibleTo": ["Designer", "AutoBending", "ManualBending", "LaserCutting", "Rubber", "Emboss"],
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
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
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
    if (oldWidget.department != widget.department || oldWidget.isPending != widget.isPending) {
      _setupStream();
    }
  }

  void _setupStream() {
    _processedDocs.clear();
    _olderDocs.clear();
    _lastDoc = null;
    _hasMore = true;

    String queryDept = widget.department == "Lasercut" ? "LaserCutting" : widget.department;
    if (widget.department == "Designer" && widget.isPending) {
      _stream = FirebaseFirestore.instance.collection("jobs").where("visibleTo", arrayContains: "Designer").orderBy("updatedAt", descending: true).limit(20).snapshots();
    } else if (widget.department == "Designer" && !widget.isPending) {
      _stream = FirebaseFirestore.instance.collection("jobs").where("visibleTo", arrayContains: "Designer").where("designer.data.DesigningStatus", isEqualTo: "Done").orderBy("updatedAt", descending: true).limit(20).snapshots();
    } else {
      // All other departments
      _stream = FirebaseFirestore.instance
          .collection("jobs")
          .where("visibleTo", arrayContains: queryDept)
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
        if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
        if (snapshot.connectionState == ConnectionState.waiting && snapshot.data == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final latestDocs = List<QueryDocumentSnapshot>.from(snapshot.data?.docs ?? []);
        if (latestDocs.isNotEmpty) _lastDoc = latestDocs.last;
        final Map<String, QueryDocumentSnapshot> uniqueDocs = {};
        for (var d in latestDocs) uniqueDocs[d.id] = d;
        for (var d in _olderDocs) uniqueDocs[d.id] = d;
        final docs = uniqueDocs.values.toList();
        final query = widget.searchText.trim().toLowerCase();
        final filtered = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final designer = (data["designer"]?["data"] ?? {}) as Map<String, dynamic>;
          final matchesSearch = doc.id.toLowerCase().contains(query) ||
              (designer["PartyName"] ?? "").toString().toLowerCase().contains(query) ||
              (designer["ParticularJobName"] ?? "").toString().toLowerCase().contains(query);
          if (query.isNotEmpty && !matchesSearch) return false;
          final designingStatus = (designer["DesigningStatus"] ?? "").toString().toLowerCase();
          final approvalStatus = (data["customerApprovalStatus"] ?? "").toString().toLowerCase();
          
          if (widget.department == "Delivery") {
            final deliveryStatus = (data["status"] ?? "").toString().toLowerCase();
            if (widget.isPending) {
              if (deliveryStatus == "delivered") return false;
            } else {
              if (deliveryStatus != "delivered") return false;
            }
            return true;
          }

          if (widget.department == "Designer") {
            if (widget.isPending) {
              if (designingStatus != "done") return true;
              if (approvalStatus == "pending") return true;
              if (approvalStatus == "changes") return true;
              return false;
            }
            if (!widget.isPending) {
              if (approvalStatus == "pending") return false;
              if (designingStatus != "done") return false;
              return true;
            }
          } else {
            if (approvalStatus == "pending") return false;
            if (designingStatus != "done") return false;
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

// ── Quotations tab (quoteDesignDone == true) ──────────────────────────────────
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
        if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));

        final docs = snapshot.data?.docs ?? [];
        final query = searchText.trim().toLowerCase();

        final filtered = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['quoteDesignDone'] != true) return false;
          if (query.isEmpty) return true;
          return doc.id.toLowerCase().contains(query) ||
              (data["PartyName"] ?? data["partyName"] ?? "").toString().toLowerCase().contains(query);
        }).toList();

        if (filtered.isEmpty) {
          return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.description_outlined, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text("No quotations yet", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey.shade400)),
          ]));
        }

        final groupedDocs = DateGroupingUtil.groupDataByDate(filtered);
        final groupedKeys = groupedDocs.keys.toList();

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: groupedKeys.length,
          itemBuilder: (context, index) {
            final dateKey = groupedKeys[index];
            final groupItems = groupedDocs[dateKey]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- BEGIN DATE-WISE GROUPING UI ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_outlined, size: 18, color: Color(0xFF6A7B8C)),
                      const SizedBox(width: 8),
                      Text(
                        dateKey,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4A5568),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${groupItems.length} Entries",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // --- END DATE-WISE GROUPING UI ---

                ...groupItems.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      onTap: () => context.push('/customer-quotation-detail/${doc.id}'),
                      title: Text(doc.id, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      subtitle: Text(data["PartyName"] ?? data["partyName"] ?? "—", style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFF8D94B).withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                        child: const Text("DONE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  );
                }).toList(),
              ],
            );
          },
        );
      },
    );
  }
}

// ── Quotation Pending tab (quoteDesignDone != true) ───────────────────────────
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
        if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));

        final docs = snapshot.data?.docs ?? [];
        final query = searchText.trim().toLowerCase();

        final filtered = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['quoteDesignDone'] != true) return false;
          if (query.isEmpty) return true;
          return doc.id.toLowerCase().contains(query) ||
              (data["PartyName"] ?? data["partyName"] ?? "").toString().toLowerCase().contains(query);
        }).toList();

        if (filtered.isEmpty) {
          return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.hourglass_empty, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text("No pending quotations", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey.shade400)),
          ]));
        }

        final groupedDocs = DateGroupingUtil.groupDataByDate(filtered);
        final groupedKeys = groupedDocs.keys.toList();

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: groupedKeys.length,
          itemBuilder: (context, index) {
            final dateKey = groupedKeys[index];
            final groupItems = groupedDocs[dateKey]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- BEGIN DATE-WISE GROUPING UI ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_outlined, size: 18, color: Color(0xFF6A7B8C)),
                      const SizedBox(width: 8),
                      Text(
                        dateKey,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4A5568),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${groupItems.length} Entries",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // --- END DATE-WISE GROUPING UI ---

                ...groupItems.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      onTap: () => context.push('/customer-quotation-detail/${doc.id}'),
                      title: Text(doc.id, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      subtitle: Text(data["PartyName"] ?? data["partyName"] ?? "—", style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.orange.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
                        child: const Text("PENDING", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  );
                }).toList(),
              ],
            );
          },
        );
      },
    );
  }
}