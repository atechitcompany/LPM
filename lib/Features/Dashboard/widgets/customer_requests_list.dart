import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomerRequestsList extends StatefulWidget {
  final String searchText;

  const CustomerRequestsList({
    super.key,
    required this.searchText,
  });

  @override
  State<CustomerRequestsList> createState() =>
      _CustomerRequestsListState();
}

class _CustomerRequestsListState extends State<CustomerRequestsList> {
  // ✅ STREAM — UNCHANGED
  Stream<QuerySnapshot>? _customerRequestsStream;

  @override
  void initState() {
    super.initState();
    _customerRequestsStream = FirebaseFirestore.instance
        .collection("customers")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _customerRequestsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs;

        if (docs.isEmpty) {
          return const Center(
              child: Text("No customer requests available"));
        }

        // ✅ SEARCH FILTER — UNCHANGED
        final query = widget.searchText.trim().toLowerCase();
        final filteredDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name =
          (data["name"] ?? "").toString().toLowerCase();
          final partyName =
          (data["partyName"] ?? "").toString().toLowerCase();
          final particularJobName =
          (data["particularJobName"] ?? "")
              .toString()
              .toLowerCase();
          if (query.isEmpty) return true;
          return name.contains(query) ||
              partyName.contains(query) ||
              particularJobName.contains(query);
        }).toList();

        if (filteredDocs.isEmpty) {
          return const Center(
              child: Text("No matching requests"));
        }

        return Container(
          color: const Color(0xFFF5F6FA),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 4),
            itemCount: filteredDocs.length,
            itemBuilder: (context, index) {
              final data = filteredDocs[index].data()
              as Map<String, dynamic>;
              final docId = filteredDocs[index].id;
              return _buildCard(context, data, docId);
            },
          ),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context,
      Map<String, dynamic> data, String docId) {
    // ✅ DATA FIELDS — UNCHANGED
    final partyName = data["partyName"] ?? "No Party";
    final particularJobName =
        data["particularJobName"] ?? "No Job";
    final priority = data["priority"] ?? "Normal";
    final deliveryAt = data["deliveryAt"] ?? "Not specified";
    final createdAt = data["createdAt"];

    String formattedDate = "N/A";
    if (createdAt != null) {
      final dateTime = (createdAt as Timestamp).toDate();
      formattedDate =
      "${dateTime.day}/${dateTime.month}/${dateTime.year}";
    }

    final Color priorityColor = _getPriorityColor(priority);
    final String priorityLabel = _getPriorityLabel(priority);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          // Blue border — exact match to screenshot
          border: Border.all(
            color: const Color(0xFF5B9BD5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          // ✅ NAVIGATION — UNCHANGED
          onTap: () =>
              context.push('/customer-request-detail/$docId'),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top section ──────────────────────────────────────
              Padding(
                padding:
                const EdgeInsets.fromLTRB(14, 14, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Avatar + Party Name + Badge
                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.center,
                      children: [
                        // Avatar
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE3F0FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            color: Color(0xFF4A90D9),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Party Name — BOLD, BIG
                        Expanded(
                          child: Text(
                            partyName.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                              color: Color(0xFF1A1A2E),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        const SizedBox(width: 8),

                        // Priority badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color:
                            priorityColor.withOpacity(0.12),
                            borderRadius:
                            BorderRadius.circular(20),
                            border: Border.all(
                                color: priorityColor, width: 1),
                          ),
                          child: Text(
                            priorityLabel,
                            style: TextStyle(
                              color: priorityColor,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Row 2: Job + Delivery + Date
                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Job: $particularJobName",
                                style: const TextStyle(
                                  color: Color(0xFF555555),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "Delivery: ",
                                      style: TextStyle(
                                        color: Colors
                                            .grey.shade600,
                                        fontSize: 14,
                                      ),
                                    ),
                                    TextSpan(
                                      text:
                                      deliveryAt.toString(),
                                      style: const TextStyle(
                                        color:
                                        Color(0xFF1A1A2E),
                                        fontSize: 14,
                                        fontWeight:
                                        FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Divider ──────────────────────────────────────────
              Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.shade200),

              // ── Accept / Reject buttons ───────────────────────────
              SizedBox(
                height: 48,
                child: Row(
                  children: [
                    // ✓ Accept — left half
                    Expanded(
                      child: InkWell(
                        onTap: () => context.push(
                            '/customer-request-detail/$docId'),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check,
                            color: Color(0xFF27AE60),
                            size: 24,
                          ),
                        ),
                      ),
                    ),

                    // Vertical divider
                    Container(
                        width: 1,
                        height: 48,
                        color: Colors.grey.shade200),

                    // ✗ Reject — right half
                    Expanded(
                      child: InkWell(
                        onTap: () => context.push(
                            '/customer-request-detail/$docId'),
                        borderRadius: const BorderRadius.only(
                          bottomRight: Radius.circular(16),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.close,
                            color: Color(0xFFE74C3C),
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ LOGIC — UNCHANGED
  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case "urgent":      return const Color(0xFFE74C3C);
      case "high":        return const Color(0xFFE74C3C);
      case "important":   return const Color(0xFF27AE60);
      case "medium":      return const Color(0xFFF39C12);
      case "emergency":   return const Color(0xFFF39C12);
      case "low":         return const Color(0xFF27AE60);
      default:            return const Color(0xFF3498DB);
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority.toLowerCase()) {
      case "high":        return "URGENT";
      case "urgent":      return "URGENT";
      case "important":   return "IMPORTANT";
      case "medium":      return "EMERGENCY";
      case "emergency":   return "EMERGENCY";
      case "low":         return "IMPORTANT";
      default:            return priority.toUpperCase();
    }
  }
}