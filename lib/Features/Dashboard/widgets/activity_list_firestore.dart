import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
                    fontWeight: FontWeight.w700, fontSize: 13),
                unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w500, fontSize: 13),
                indicator: const UnderlineTabIndicator(
                  borderSide:
                  BorderSide(width: 3, color: Color(0xFFF8D94B)),
                  insets: EdgeInsets.symmetric(horizontal: 12),
                ),
                tabs: const [
                  Tab(text: "Pending"),
                  Tab(text: "Jobs"),
                  Tab(text: "Quotations"),
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
                  const _KeepAliveTab(
                    child: _EmptyQuotations(),
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

  @override
  void initState() {
    super.initState();
    _setupStream();
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
    if (widget.isPending && widget.department == "Designer") {
      // Designer pending tab — show jobs where designing not yet done
      _stream = FirebaseFirestore.instance
          .collection("jobs")
          .where("visibleTo", arrayContains: "Designer")
          .where("currentDepartment", isEqualTo: "Designer")
          .orderBy("updatedAt", descending: true)
          .snapshots();
    } else {
      // All other departments + Designer Jobs tab
      _stream = FirebaseFirestore.instance
          .collection("jobs")
          .where("visibleTo", arrayContains: widget.department)
          .orderBy("updatedAt", descending: true)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_stream == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          debugPrint("❌ Stream error: ${snapshot.error}");
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            snapshot.data == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = List<QueryDocumentSnapshot>.from(
            snapshot.data?.docs ?? []);

        // Search filter
        final query = widget.searchText.trim().toLowerCase();
        final filtered = docs.where((doc) {
          final d = ((doc.data() as Map<String, dynamic>)["designer"]
          ?["data"]) ??
              {};
          final party =
          (d["partyName"] ?? d["PartyName"] ?? "")
              .toString()
              .toLowerCase();
          final job =
          (d["particularJobName"] ?? d["ParticularJobName"] ?? "")
              .toString()
              .toLowerCase();
          if (query.isEmpty) return true;
          return party.contains(query) || job.contains(query);
        }).toList();

        return ActivityList(
          docs: filtered,
          isPending: widget.isPending,
          isQuotation: false,
          hasMore: false,
          isLoadingMore: false,
          scrollController: _scrollController,
        );
      },
    );
  }
}