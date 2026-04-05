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

  // ✅ ACCEPT LOGIC — UNCHANGED
  Future<void> _acceptRequest(BuildContext context, String docId,
      Map<String, dynamic> customerData) async {
    try {
      final counterRef = FirebaseFirestore.instance
          .collection("counters")
          .doc("jobCounter");

      int nextLpm = 1001;
      final snap = await counterRef.get();
      if (snap.exists) {
        final val = snap.data()?["lastLpm"];
        if (val is int) {
          nextLpm = val + 1;
        } else if (val is String) {
          nextLpm = (int.tryParse(val) ?? 1000) + 1;
        }
      } else {
        await counterRef.set({"lastLpm": 1001});
        nextLpm = 1002;
      }

      await FirebaseFirestore.instance
          .collection("jobs")
          .doc(nextLpm.toString())
          .set({
        "lpm": nextLpm.toString(),
        "currentDepartment": "Designer",
        "status": "pending_designer_review",
        "acceptedAt": FieldValue.serverTimestamp(),
        "designer": {
          "submitted": false,
          "data": {
            "name": customerData["name"] ?? "",
            "partyName": customerData["partyName"] ?? "",
            "particularJobName": customerData["particularJobName"] ?? "",
            "orderBy": customerData["orderBy"] ?? "",
            "deliveryAt": customerData["deliveryAt"] ?? "",
            "priority": customerData["priority"] ?? "Normal",
            "remark": customerData["remark"] ?? "",
            "designedBy": "",
            "plyType": "No",
            "plySelectedBy": "",
            "blade": "No",
            "bladeSelectedBy": "",
            "creasing": "No",
            "creasingSelectedBy": "",
            "capsuleType": "",
            "unknown": "",
            "perforation": "No",
            "perforationSelectedBy": "",
            "zigZagBlade": "No",
            "zigZagBladeSelectedBy": "",
            "rubberType": "No",
            "rubberSelectedBy": "",
            "holeType": "No",
            "holeSelectedBy": "",
            "embossStatus": "No",
            "embossPcs": "",
            "maleEmbossType": "No",
            "femaleEmbossType": "No",
            "x": "",
            "y": "",
            "x2": "",
            "y2": "",
            "strippingType": "No",
            "laserCuttingStatus": "Pending",
            "rubberFixingDone": "No",
            "whiteProfileRubber": "No",
          },
        },
        "autoBending": {"submitted": false},
        "manualBending": {"submitted": false},
        "laserCut": {"submitted": false},
        "emboss": {"submitted": false},
        "rubber": {"submitted": false},
        "account": {"submitted": false},
        "delivery": {"submitted": false},
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });

      await counterRef.update({"lastLpm": nextLpm});

      await FirebaseFirestore.instance
          .collection("customers")
          .doc(docId)
          .delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Request accepted! LPM: $nextLpm'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('❌ Error: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  // ✅ REJECT LOGIC — saves to "rejectedRequests" before deleting
  Future<void> _rejectRequest(BuildContext context, String docId,
      Map<String, dynamic> customerData) async {
    try {
      // Step 1: Save full data to rejectedRequests collection
      await FirebaseFirestore.instance
          .collection("rejectedRequests")
          .add({
        ...customerData,                              // all original fields
        "originalDocId": docId,                      // original doc reference
        "rejectedAt": FieldValue.serverTimestamp(),  // rejection timestamp
        "status": "rejected",
      });

      // Step 2: Delete from customers collection
      await FirebaseFirestore.instance
          .collection("customers")
          .doc(docId)
          .delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Request rejected and saved'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showAcceptDialog(BuildContext context, String docId,
      Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Accept"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Are you sure you want to accept this request?"),
            const SizedBox(height: 12),
            Text("Customer: ${data['partyName'] ?? 'N/A'}",
                style: const TextStyle(fontWeight: FontWeight.w500)),
            Text("Job: ${data['particularJobName'] ?? 'N/A'}",
                style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _acceptRequest(context, docId, data);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white),
            child: const Text("Accept"),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, String docId,
      Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Rejection"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "⚠️ Are you sure you want to reject this request?",
              style: TextStyle(
                  fontWeight: FontWeight.w500, color: Colors.red),
            ),
            const SizedBox(height: 12),
            Text("Customer: ${data['partyName'] ?? 'N/A'}",
                style: const TextStyle(fontWeight: FontWeight.w500)),
            Text("Job: ${data['particularJobName'] ?? 'N/A'}",
                style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            const Text(
              "This action cannot be undone. The request will be saved in rejected records.",
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _rejectRequest(context, docId, data);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white),
            child: const Text("Reject"),
          ),
        ],
      ),
    );
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
              .toString().toLowerCase();
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
    final partyName = data["partyName"] ?? "No Party";
    final particularJobName = data["particularJobName"] ?? "No Job";
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InkWell(
          onTap: () =>
              context.push('/customer-request-detail/$docId'),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: Color(0xFFE3F0FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person_outline,
                              color: Color(0xFF4A90D9), size: 24),
                        ),
                        const SizedBox(width: 12),
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
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: priorityColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                text: TextSpan(children: [
                                  TextSpan(
                                    text: "Delivery: ",
                                    style: TextStyle(
                                        color: Colors.grey.shade600,
                                        fontSize: 14),
                                  ),
                                  TextSpan(
                                    text: deliveryAt.toString(),
                                    style: const TextStyle(
                                      color: Color(0xFF1A1A2E),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ]),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(formattedDate,
                            style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.shade200),
              SizedBox(
                height: 48,
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () =>
                            _showAcceptDialog(context, docId, data),
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(16)),
                        child: const Center(
                          child: Icon(Icons.check,
                              color: Color(0xFF27AE60), size: 24),
                        ),
                      ),
                    ),
                    Container(
                        width: 1,
                        height: 48,
                        color: Colors.grey.shade200),
                    Expanded(
                      child: InkWell(
                        onTap: () =>
                            _showRejectDialog(context, docId, data),
                        borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(16)),
                        child: const Center(
                          child: Icon(Icons.close,
                              color: Color(0xFFE74C3C), size: 24),
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

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case "urgent":    return const Color(0xFFE74C3C);
      case "high":      return const Color(0xFFE74C3C);
      case "important": return const Color(0xFF27AE60);
      case "medium":    return const Color(0xFFF39C12);
      case "emergency": return const Color(0xFFF39C12);
      case "low":       return const Color(0xFF27AE60);
      default:          return const Color(0xFF3498DB);
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority.toLowerCase()) {
      case "high":      return "URGENT";
      case "urgent":    return "URGENT";
      case "important": return "IMPORTANT";
      case "medium":    return "EMERGENCY";
      case "emergency": return "EMERGENCY";
      case "low":       return "IMPORTANT";
      default:          return priority.toUpperCase();
    }
  }
}