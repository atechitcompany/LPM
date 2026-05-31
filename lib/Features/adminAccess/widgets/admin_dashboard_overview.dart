// --- BEGIN ADMIN DASHBOARD OVERVIEW SECTIONS ---
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lightatech/Features/Dashboard/widgets/activity_list.dart';

class AdminDashboardOverview extends StatefulWidget {
  final String searchText;

  const AdminDashboardOverview({super.key, required this.searchText});

  @override
  State<AdminDashboardOverview> createState() => _AdminDashboardOverviewState();
}

class _AdminDashboardOverviewState extends State<AdminDashboardOverview> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
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
                Tab(text: "Job Pending"),
                Tab(text: "Job done"),
                Tab(text: "Quote Pending"),
                Tab(text: "Quote"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _KeepAliveTab(child: _AdminJobsTab(searchText: widget.searchText, isDone: false)),
                _KeepAliveTab(child: _AdminJobsTab(searchText: widget.searchText, isDone: true)),
                _KeepAliveTab(child: _AdminQuotationsTab(searchText: widget.searchText, isDone: false)),
                _KeepAliveTab(child: _AdminQuotationsTab(searchText: widget.searchText, isDone: true)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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

// ── Admin Jobs Tab ───────────────────────────────────────────────────────────
class _AdminJobsTab extends StatefulWidget {
  final String searchText;
  final bool isDone;

  const _AdminJobsTab({required this.searchText, required this.isDone});

  @override
  State<_AdminJobsTab> createState() => _AdminJobsTabState();
}

class _AdminJobsTabState extends State<_AdminJobsTab> {
  final ScrollController _scrollController = ScrollController();
  Stream<QuerySnapshot>? _stream;

  @override
  void initState() {
    super.initState();
    _setupStream();
  }

  void _setupStream() {
    _stream = FirebaseFirestore.instance
        .collection("jobs")
        .orderBy("updatedAt", descending: true)
        .limit(100)
        .snapshots();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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

        final docs = snapshot.data?.docs ?? [];
        final query = widget.searchText.trim().toLowerCase();

        final filtered = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final designer = (data["designer"]?["data"] ?? {}) as Map<String, dynamic>;
          
          final matchesSearch = doc.id.toLowerCase().contains(query) ||
              (designer["PartyName"] ?? "").toString().toLowerCase().contains(query) ||
              (designer["ParticularJobName"] ?? "").toString().toLowerCase().contains(query);

          if (query.isNotEmpty && !matchesSearch) return false;

          final currentDept = (data["currentDepartment"] ?? "").toString();
          
          if (widget.isDone) {
            return currentDept == "Completed";
          } else {
            return currentDept != "Completed";
          }
        }).toList();

        return ActivityList(
          docs: filtered,
          isPending: !widget.isDone,
          isQuotation: false,
          hasMore: false,
          isLoadingMore: false,
          scrollController: _scrollController,
        );
      },
    );
  }
}

// ── Admin Quotations Tab ──────────────────────────────────────────────────────
class _AdminQuotationsTab extends StatelessWidget {
  final String searchText;
  final bool isDone;

  const _AdminQuotationsTab({required this.searchText, required this.isDone});

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
          
          if (isDone) {
            if (data['quoteDesignDone'] != true) return false;
          } else {
            if (data['quoteDesignDone'] == true) return false;
          }

          if (query.isEmpty) return true;
          return doc.id.toLowerCase().contains(query) ||
              (data["PartyName"] ?? data["partyName"] ?? "").toString().toLowerCase().contains(query);
        }).toList();

        if (filtered.isEmpty) {
          return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(
              isDone ? Icons.description_outlined : Icons.hourglass_empty,
              size: 56, 
              color: Colors.grey.shade300
            ),
            const SizedBox(height: 12),
            Text(
              isDone ? "No done quotations" : "No pending quotations", 
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.grey.shade400)
            ),
          ]));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final doc = filtered[index];
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
                  decoration: BoxDecoration(
                    color: isDone ? const Color(0xFFF8D94B).withValues(alpha: 0.2) : Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isDone ? "DONE" : "PENDING", 
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)
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
// --- END ADMIN DASHBOARD OVERVIEW SECTIONS ---
