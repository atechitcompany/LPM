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
  static const int _pageSize = 20;

  // ── Jobs ──────────────────────────────────────────────────────────────────
  Stream<QuerySnapshot>? _jobsStream;           // real-time first page
  List<QueryDocumentSnapshot> _jobsExtra = [];  // older pages fetched manually
  DocumentSnapshot? _lastJobsDoc;
  bool _hasMoreJobs = true;
  bool _isLoadingMoreJobs = false;

  // ── Pending ───────────────────────────────────────────────────────────────
  Stream<QuerySnapshot>? _pendingStream;
  List<QueryDocumentSnapshot> _pendingExtra = [];
  DocumentSnapshot? _lastPendingDoc;
  bool _hasMorePending = true;
  bool _isLoadingMorePending = false;

  // ── Scroll controllers ────────────────────────────────────────────────────
  final ScrollController _jobsScrollController = ScrollController();
  final ScrollController _pendingScrollController = ScrollController();
  final ScrollController _quotationsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _jobsScrollController.addListener(_onJobsScroll);
    _pendingScrollController.addListener(_onPendingScroll);
    _quotationsScrollController.addListener(_onQuotationsScroll);
    _setupStreams();
  }

  @override
  void dispose() {
    _jobsScrollController.dispose();
    _pendingScrollController.dispose();
    _quotationsScrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ActivityListFirestore oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.department != widget.department ||
        oldWidget.searchText != widget.searchText) {
      _resetAll();
    }
  }

  // ── Stream setup ──────────────────────────────────────────────────────────

  void _setupStreams() {
    if (!_isValidDepartment(widget.department)) return;

    final deptKey = _deptKey(widget.department);

    // Stream listens to first page in real-time.
    // Any new doc added to Firestore shows up here instantly — no refresh needed.
    _jobsStream = FirebaseFirestore.instance
        .collection("jobs")
        .where("$deptKey.submitted", isEqualTo: true)
        .orderBy("updatedAt", descending: true)
        .limit(_pageSize)
        .snapshots();

    if (widget.department == "Designer") {
      _pendingStream = FirebaseFirestore.instance
          .collection("jobs")
          .where("status", isEqualTo: "pending_designer_review")
          .orderBy("updatedAt", descending: true)
          .limit(_pageSize)
          .snapshots();
    }
  }

  void _resetAll() {
    setState(() {
      _jobsExtra = [];
      _pendingExtra = [];
      _lastJobsDoc = null;
      _lastPendingDoc = null;
      _hasMoreJobs = true;
      _hasMorePending = true;
      _isLoadingMoreJobs = false;
      _isLoadingMorePending = false;
    });
    _setupStreams();
  }

  // ── Scroll listeners ──────────────────────────────────────────────────────

  void _onJobsScroll() {
    if (_jobsScrollController.hasClients &&
        _jobsScrollController.position.pixels >=
            _jobsScrollController.position.maxScrollExtent - 200) {
      _loadMoreJobs();
    }
  }

  void _onPendingScroll() {
    if (_pendingScrollController.hasClients &&
        _pendingScrollController.position.pixels >=
            _pendingScrollController.position.maxScrollExtent - 200) {
      _loadMorePending();
    }
  }

  void _onQuotationsScroll() {
    if (_quotationsScrollController.hasClients &&
        _quotationsScrollController.position.pixels >=
            _quotationsScrollController.position.maxScrollExtent - 200) {
      _loadMoreJobs();
    }
  }

  // ── Pagination (load older docs beyond first page) ────────────────────────

  Future<void> _loadMoreJobs({List<QueryDocumentSnapshot>? streamDocs}) async {
    if (_isLoadingMoreJobs || !_hasMoreJobs) return;
    setState(() => _isLoadingMoreJobs = true);

    try {
      final deptKey = _deptKey(widget.department);

      // Cursor: use last extra doc, or fall back to last doc from stream
      final lastDoc = _lastJobsDoc ??
          (streamDocs != null && streamDocs.isNotEmpty
              ? streamDocs.last
              : null);

      if (lastDoc == null) {
        setState(() {
          _isLoadingMoreJobs = false;
          _hasMoreJobs = false;
        });
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection("jobs")
          .where("$deptKey.submitted", isEqualTo: true)
          .orderBy("updatedAt", descending: true)
          .startAfterDocument(lastDoc)
          .limit(_pageSize)
          .get();

      if (mounted) {
        setState(() {
          _jobsExtra.addAll(snapshot.docs);
          if (snapshot.docs.isNotEmpty) _lastJobsDoc = snapshot.docs.last;
          _hasMoreJobs = snapshot.docs.length == _pageSize;
          _isLoadingMoreJobs = false;
        });
      }
    } catch (e) {
      debugPrint("❌ Error loading more jobs: $e");
      if (mounted) setState(() => _isLoadingMoreJobs = false);
    }
  }

  Future<void> _loadMorePending(
      {List<QueryDocumentSnapshot>? streamDocs}) async {
    if (_isLoadingMorePending || !_hasMorePending) return;
    setState(() => _isLoadingMorePending = true);

    try {
      final lastDoc = _lastPendingDoc ??
          (streamDocs != null && streamDocs.isNotEmpty
              ? streamDocs.last
              : null);

      if (lastDoc == null) {
        setState(() {
          _isLoadingMorePending = false;
          _hasMorePending = false;
        });
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection("jobs")
          .where("status", isEqualTo: "pending_designer_review")
          .orderBy("updatedAt", descending: true)
          .startAfterDocument(lastDoc)
          .limit(_pageSize)
          .get();

      if (mounted) {
        setState(() {
          _pendingExtra.addAll(snapshot.docs);
          if (snapshot.docs.isNotEmpty) _lastPendingDoc = snapshot.docs.last;
          _hasMorePending = snapshot.docs.length == _pageSize;
          _isLoadingMorePending = false;
        });
      }
    } catch (e) {
      debugPrint("❌ Error loading more pending: $e");
      if (mounted) setState(() => _isLoadingMorePending = false);
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

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
                  _buildStreamSection(
                    stream: _jobsStream,
                    extraDocs: _jobsExtra,
                    isPending: false,
                    isQuotation: false,
                    hasMore: _hasMoreJobs,
                    isLoadingMore: _isLoadingMoreJobs,
                    scrollController: _jobsScrollController,
                    onLoadMore: _loadMoreJobs,
                  ),
                  _buildStreamSection(
                    stream: _pendingStream,
                    extraDocs: _pendingExtra,
                    isPending: true,
                    isQuotation: false,
                    hasMore: _hasMorePending,
                    isLoadingMore: _isLoadingMorePending,
                    scrollController: _pendingScrollController,
                    onLoadMore: _loadMorePending,
                  ),
                  _buildStreamSection(
                    stream: _jobsStream,
                    extraDocs: _jobsExtra,
                    isPending: false,
                    isQuotation: true,
                    hasMore: _hasMoreJobs,
                    isLoadingMore: _isLoadingMoreJobs,
                    scrollController: _quotationsScrollController,
                    onLoadMore: _loadMoreJobs,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return _buildStreamSection(
      stream: _jobsStream,
      extraDocs: _jobsExtra,
      isPending: false,
      isQuotation: false,
      hasMore: _hasMoreJobs,
      isLoadingMore: _isLoadingMoreJobs,
      scrollController: _jobsScrollController,
      onLoadMore: _loadMoreJobs,
    );
  }

  Widget _buildStreamSection({
    required Stream<QuerySnapshot>? stream,
    required List<QueryDocumentSnapshot> extraDocs,
    required bool isPending,
    required bool isQuotation,
    required bool hasMore,
    required bool isLoadingMore,
    required ScrollController scrollController,
    required Function({List<QueryDocumentSnapshot>? streamDocs}) onLoadMore,
  }) {
    if (stream == null) {
      return const Center(child: Text("No data available"));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final streamDocs =
        List<QueryDocumentSnapshot>.from(snapshot.data?.docs ?? []);

        // Merge stream docs (real-time) + extra docs (paginated older pages).
        // De-duplicate by doc ID to avoid showing same item twice.
        final seenIds = <String>{};
        final merged = <QueryDocumentSnapshot>[];
        for (final doc in [...streamDocs, ...extraDocs]) {
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
            // Trigger pagination when scrolled near bottom
            if (notification is ScrollEndNotification &&
                notification.metrics.pixels >=
                    notification.metrics.maxScrollExtent - 200) {
              onLoadMore(streamDocs: streamDocs);
            }
            return false;
          },
          child: ActivityList(
            docs: filtered,
            isPending: isPending,
            isQuotation: isQuotation,
            hasMore: hasMore,
            isLoadingMore: isLoadingMore,
            scrollController: scrollController,
          ),
        );
      },
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

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