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
                  Tab(text: "Jobs"),
                  Tab(text: "Pending"),
                  Tab(text: "Quotations"),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _KeepAliveTab(
                    child: _FirestoreTab(
                      department: widget.department,
                      searchText: widget.searchText,
                      isPending: false,
                    ),
                  ),
                  _KeepAliveTab(
                    child: _FirestoreTab(
                      department: widget.department,
                      searchText: widget.searchText,
                      isPending: true,
                    ),
                  ),
                  // ── Quotations: empty for now ─────────────────────────
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
      "Lasercut",
      "Emboss",
      "Rubber",
      "Account",
      "Delivery",
    ].contains(dept);
  }
}

// ── Empty Quotations placeholder ──────────────────────────────────────────────
class _EmptyQuotations extends StatelessWidget {
  const _EmptyQuotations();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.description_outlined, size: 56, color: Colors.grey.shade300),
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

// ── Single tab: stream + pagination ──────────────────────────────────────────
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
  static const int _pageSize = 20;

  Stream<QuerySnapshot>? _stream;
  List<QueryDocumentSnapshot> _extraDocs = [];
  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
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
    if (oldWidget.department != widget.department) {
      _reset();
    }
  }

  void _setupStream() {
    if (widget.isPending) {
      _stream = FirebaseFirestore.instance
          .collection("jobs")
          .where("status", isEqualTo: "pending_designer_review")
          .orderBy("updatedAt", descending: true)
          .limit(_pageSize)
          .snapshots();
    } else {
      _stream = FirebaseFirestore.instance
          .collection("jobs")
          .where("visibleTo", arrayContains: widget.department)
          .orderBy("updatedAt", descending: true)
          .limit(_pageSize)
          .snapshots();
    }
  }

  void _reset() {
    setState(() {
      _extraDocs = [];
      _lastDoc = null;
      _hasMore = true;
      _isLoadingMore = false;
    });
    _setupStream();
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore({List<QueryDocumentSnapshot>? streamDocs}) async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);

    try {
      final lastDoc = _lastDoc ??
          (streamDocs != null && streamDocs.isNotEmpty
              ? streamDocs.last
              : null);

      if (lastDoc == null) {
        setState(() {
          _isLoadingMore = false;
          _hasMore = false;
        });
        return;
      }

      Query query;
      if (widget.isPending) {
        query = FirebaseFirestore.instance
            .collection("jobs")
            .where("status", isEqualTo: "pending_designer_review")
            .orderBy("updatedAt", descending: true)
            .startAfterDocument(lastDoc)
            .limit(_pageSize);
      } else {
        query = FirebaseFirestore.instance
            .collection("jobs")
            .where("visibleTo", arrayContains: widget.department)
            .orderBy("updatedAt", descending: true)
            .startAfterDocument(lastDoc)
            .limit(_pageSize);
      }

      final snapshot = await query.get();

      if (mounted) {
        setState(() {
          _extraDocs.addAll(snapshot.docs);
          if (snapshot.docs.isNotEmpty) _lastDoc = snapshot.docs.last;
          _hasMore = snapshot.docs.length == _pageSize;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      debugPrint("❌ Error loading more: $e");
      if (mounted) setState(() => _isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_stream == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            snapshot.data == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final streamDocs =
        List<QueryDocumentSnapshot>.from(snapshot.data?.docs ?? []);

        // Merge stream + paginated extra, de-duplicate by ID
        final seenIds = <String>{};
        final merged = <QueryDocumentSnapshot>[];
        for (final doc in [...streamDocs, ..._extraDocs]) {
          if (seenIds.add(doc.id)) merged.add(doc);
        }

        // Search filter
        final query = widget.searchText.trim().toLowerCase();
        final filtered = merged.where((doc) {
          final d =
              ((doc.data() as Map<String, dynamic>)["designer"]?["data"]) ??
                  {};
          final party = (d["partyName"] ?? d["PartyName"] ?? "")
              .toString()
              .toLowerCase();
          final job =
          (d["particularJobName"] ?? d["ParticularJobName"] ?? "")
              .toString()
              .toLowerCase();
          if (query.isEmpty) return true;
          return party.contains(query) || job.contains(query);
        }).toList();

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollEndNotification &&
                notification.metrics.pixels >=
                    notification.metrics.maxScrollExtent - 200) {
              _loadMore(streamDocs: streamDocs);
            }
            return false;
          },
          child: ActivityList(
            docs: filtered,
            isPending: widget.isPending,
            isQuotation: false,
            hasMore: _hasMore,
            isLoadingMore: _isLoadingMore,
            scrollController: _scrollController,
          ),
        );
      },
    );
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