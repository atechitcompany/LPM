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
  static const int _pageSize = 10;

  List<QueryDocumentSnapshot> _jobsDocs = [];
  List<QueryDocumentSnapshot> _pendingDocs = [];

  DocumentSnapshot? _lastJobsDoc;
  DocumentSnapshot? _lastPendingDoc;

  bool _hasMoreJobs = true;
  bool _hasMorePending = true;

  bool _isLoadingJobs = false;
  bool _isLoadingPending = false;

  // Scroll controllers for each tab
  final ScrollController _jobsScrollController = ScrollController();
  final ScrollController _pendingScrollController = ScrollController();
  final ScrollController _quotationsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Attach scroll listeners
    _jobsScrollController.addListener(_onJobsScroll);
    _pendingScrollController.addListener(_onPendingScroll);
    _quotationsScrollController.addListener(_onJobsScroll); // Quotations reuse jobs data

    if (_isValidDepartment(widget.department)) {
      _fetchJobs(isInitial: true);
      if (widget.department == "Designer") {
        _fetchPending(isInitial: true);
      }
    }
  }

  @override
  void dispose() {
    _jobsScrollController.dispose();
    _pendingScrollController.dispose();
    _quotationsScrollController.dispose();
    super.dispose();
  }

  /// Triggered when user scrolls near the bottom of the Jobs list.
  void _onJobsScroll() {
    final controller = _jobsScrollController.hasClients
        ? _jobsScrollController
        : null;
    if (controller == null) return;
    if (controller.position.pixels >=
        controller.position.maxScrollExtent - 200) {
      _fetchJobs();
    }
  }

  /// Triggered when user scrolls near the bottom of the Pending list.
  void _onPendingScroll() {
    if (!_pendingScrollController.hasClients) return;
    if (_pendingScrollController.position.pixels >=
        _pendingScrollController.position.maxScrollExtent - 200) {
      _fetchPending();
    }
  }

  @override
  void didUpdateWidget(ActivityListFirestore oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.department != widget.department ||
        oldWidget.searchText != widget.searchText) {
      _refreshAll();
    }
  }

  void _refreshAll() {
    setState(() {
      _jobsDocs = [];
      _pendingDocs = [];
      _lastJobsDoc = null;
      _lastPendingDoc = null;
      _hasMoreJobs = true;
      _hasMorePending = true;
    });
    _fetchJobs(isInitial: true);
    if (widget.department == "Designer") {
      _fetchPending(isInitial: true);
    }
  }

  Future<void> _fetchJobs({bool isInitial = false}) async {
    if (_isLoadingJobs || (!_hasMoreJobs && !isInitial)) return;

    setState(() => _isLoadingJobs = true);

    try {
      final deptKey = _deptKey(widget.department);
      Query query = FirebaseFirestore.instance
          .collection("jobs")
          .where("$deptKey.submitted", isEqualTo: true)
          .orderBy("updatedAt", descending: true)
          .limit(_pageSize);

      if (!isInitial && _lastJobsDoc != null) {
        query = query.startAfterDocument(_lastJobsDoc!);
      }

      final snapshot = await query.get();

      if (mounted) {
        setState(() {
          if (isInitial) _jobsDocs = [];
          _jobsDocs.addAll(snapshot.docs);
          _lastJobsDoc = snapshot.docs.isNotEmpty
              ? snapshot.docs.last
              : _lastJobsDoc;
          _hasMoreJobs = snapshot.docs.length == _pageSize;
          _isLoadingJobs = false;
        });
      }
    } catch (e) {
      debugPrint("❌ Error fetching jobs: $e");
      if (mounted) {
        setState(() {
          _isLoadingJobs = false;
          _hasMoreJobs = false;
        });
      }
    }
  }

  Future<void> _fetchPending({bool isInitial = false}) async {
    if (_isLoadingPending || (!_hasMorePending && !isInitial)) return;

    setState(() => _isLoadingPending = true);

    try {
      Query query = FirebaseFirestore.instance
          .collection("jobs")
          .where("status", isEqualTo: "pending_designer_review")
          .orderBy("updatedAt", descending: true)
          .limit(_pageSize);

      if (!isInitial && _lastPendingDoc != null) {
        query = query.startAfterDocument(_lastPendingDoc!);
      }

      final snapshot = await query.get();

      if (mounted) {
        setState(() {
          if (isInitial) _pendingDocs = [];
          _pendingDocs.addAll(snapshot.docs);
          _lastPendingDoc = snapshot.docs.isNotEmpty
              ? snapshot.docs.last
              : _lastPendingDoc;
          _hasMorePending = snapshot.docs.length == _pageSize;
          _isLoadingPending = false;
        });
      }
    } catch (e) {
      debugPrint("❌ Error fetching pending: $e");
      if (mounted) {
        setState(() {
          _isLoadingPending = false;
          _hasMorePending = false;
        });
      }
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
                  _buildSection(
                    docs: _jobsDocs,
                    isPending: false,
                    isQuotation: false,
                    hasMore: _hasMoreJobs,
                    isLoading: _isLoadingJobs,
                    scrollController: _jobsScrollController,
                  ),
                  _buildSection(
                    docs: _pendingDocs,
                    isPending: true,
                    isQuotation: false,
                    hasMore: _hasMorePending,
                    isLoading: _isLoadingPending,
                    scrollController: _pendingScrollController,
                  ),
                  _buildSection(
                    docs: _jobsDocs,
                    isPending: false,
                    isQuotation: true,
                    hasMore: _hasMoreJobs,
                    isLoading: _isLoadingJobs,
                    scrollController: _quotationsScrollController,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return _buildSection(
      docs: _jobsDocs,
      isPending: false,
      isQuotation: false,
      hasMore: _hasMoreJobs,
      isLoading: _isLoadingJobs,
      scrollController: _jobsScrollController,
    );
  }

  Widget _buildSection({
    required List<QueryDocumentSnapshot> docs,
    required bool isPending,
    required bool isQuotation,
    required bool hasMore,
    required bool isLoading,
    required ScrollController scrollController,
  }) {
    // Full-screen loader only on the very first fetch
    if (isLoading && docs.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final query = widget.searchText.trim().toLowerCase();
    final filtered = docs.where((doc) {
      final d =
          ((doc.data() as Map<String, dynamic>)["designer"]?["data"]) ?? {};
      final party =
      (d["partyName"] ?? d["PartyName"] ?? "").toString().toLowerCase();
      final job = (d["particularJobName"] ?? d["ParticularJobName"] ?? "")
          .toString()
          .toLowerCase();
      if (query.isEmpty) return true;
      return party.contains(query) || job.contains(query);
    }).toList();

    return ActivityList(
      docs: filtered,
      isPending: isPending,
      isQuotation: isQuotation,
      hasMore: hasMore,
      isLoadingMore: isLoading,
      scrollController: scrollController, // pass controller down
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