import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomerRequestsScreen extends StatefulWidget {
  const CustomerRequestsScreen({super.key});

  @override
  State<CustomerRequestsScreen> createState() =>
      _CustomerRequestsScreenState();
}

class _CustomerRequestsScreenState
    extends State<CustomerRequestsScreen> with SingleTickerProviderStateMixin {
  final searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;

  List<QueryDocumentSnapshot> _olderDocs = [];
  bool _isLoadingMore = false;
  bool _hasMore = true;
  DocumentSnapshot? _lastDoc;

  Stream<QuerySnapshot>? _customerRequestsStream;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _customerRequestsStream = FirebaseFirestore.instance
        .collection("demo_customer_form")
        .orderBy("submittedAt", descending: true)
        .limit(50)
        .snapshots();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMore();
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore || _lastDoc == null) return;
    setState(() => _isLoadingMore = true);

    final snap = await FirebaseFirestore.instance
        .collection("demo_customer_form")
        .orderBy("submittedAt", descending: true)
        .startAfterDocument(_lastDoc!)
        .limit(50)
        .get();

    if (snap.docs.isNotEmpty) {
      _olderDocs.addAll(snap.docs);
      _lastDoc = snap.docs.last;
    } else {
      _hasMore = false;
    }

    setState(() => _isLoadingMore = false);
  }

  Future<String> _generateLpm() async {
    try {
      final counterRef = FirebaseFirestore.instance
          .collection("counters")
          .doc("demo_counter");
      final snap = await counterRef.get();
      int lastNo = 0;
      if (snap.exists) {
        lastNo = snap.data()?["lastNo"] ?? 0;
      }
      final fullLpm = "demo${lastNo + 1}";
      debugPrint("✅ Demo LPM: $fullLpm");
      return fullLpm;
    } catch (e) {
      debugPrint("❌ Demo LPM error: $e");
      return "demo_fallback_${DateTime.now().millisecondsSinceEpoch}";
    }
  }

  Future<void> _incrementMonthlyCounter() async {
    final counterRef = FirebaseFirestore.instance
        .collection("counters")
        .doc("demo_counter");
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snap = await transaction.get(counterRef);
      int lastNo = 0;
      if (snap.exists) lastNo = snap.data()?["lastNo"] ?? 0;
      transaction.set(counterRef, {"lastNo": lastNo + 1}, SetOptions(merge: true));
    });
  }

  Map<String, dynamic> _buildDesignerData(Map<String, dynamic> customerData) {
    return {
      "LpmAutoIncrement": "",
      "BuyerOrderNo": customerData["buyerOrderNo"] ?? "",
      "DeliveryAt": customerData["deliveryAt"] ?? "",
      "Orderby": customerData["orderBy"] ?? "",
      "Remark": customerData["remark"] ?? "NO REMARK",
      "Ups": "NO",
      "PartyworkName": "NO",
      "Size": "NO",
      "Size2": "NO",
      "Size3": "NO",
      "Size4": "NO",
      "Size5": "NO",
      "Ups_32": "",
      "PlyLength": "",
      "PlyBreadth": "",
      "Blade": "No",
      "BladeSize": "",
      "Extra": "",
      "Creasing": "No",
      "CreasingSize": "",
      "CapsuleType": customerData["capsuleType"] ?? "",
      "CapsuleRate": "",
      "CapsulePcs": "",
      "CapsuleAmt": "",
      "ZigZagBlade": "No",
      "PerforationSize": "",
      "ZigZagBladeType": "",
      "ZigZagBladeSize": "",
      "RubberType": "No",
      "RubberSize": "",
      "RubberDoneBy": "",
      "HoleType": "No",
      "EmbossPcs": "No",
      "TotalSize": "No",
      "MinimumChargeApply": "",
      "MaleEmbossType": "No",
      "MaleRate": "",
      "X": "",
      "Y": "",
      "XYSize": "",
      "FemaleEmbossType": "No",
      "FemaleRate": "",
      "X2": "",
      "Y2": "",
      "XY2Size": "",
      "StrippingType": "No",
      "StrippingSize": "",
      "CourierCharges": "",
      "LaserPunchNew": "No",
      "LaserRate": "",
      "LaserDoneBy": "",
      "LaserCuttingStatus": "Pending",
      "AutoBendingDoneBy": "",
      "FullAddress": "",
      "DeliveryURL": "URL",
      "Unknown": "",
      "DesignSendBy": "",
      "ReceiverName": "",
      "TransportName": "",
      "DesigningStatus": "Pending",
      "ManualBendingStatus": "Pending",
      "AutobendingStatus": "Pending",
      "DeliveryStatus": "Pending",
      "EmbossStatus": "No",
      "AutoCreasingStatus": "",
      "InvoiceStatus": "Pending",
      "InvoicePrintedBy": "",
      "CreatedBy": "",
      "DesignerCreatedBy": "",
      "AutoBendingCreatedBy": "",
      "LaserCuttingCreatedBy": "",
      "AccountsCreatedBy": "",
      "EmbossCreatedBy": "",
      "ManualBendingCreatedBy": "",
      "ManualBendingFittingDoneBy": "",
      "DeliveryCreatedBy": "",
      "GSTType": "",
      "PartyName": customerData["partyName"] ?? "",
      "particularJobName": customerData["jobName"] ?? "",
      "Priority": customerData["priority"] ?? "Normal",
      "PlyType": "No",
      "Amounts3": "",
      "ParticularSlider": "",
      "RubberFixingDone": "No",
      "WhiteProfileRubber": "No",
      "Perforation": "No",
      "DesignedBy": "",
      "PlySelectedBy": "",
      "BladeSelectedBy": "",
      "CreasingSelectedBy": "",
      "PerforationSelectedBy": "",
      "ZigZagBladeSelectedBy": "",
      "RubberSelectedBy": "",
      "HoleSelectedBy": "",
      "Timestamp": DateTime.now().toIso8601String(),
    };
  }

  // ✅ FIX: Always re-fetch the full document from Firestore using docId.
  // This ensures all fields are available regardless of whether accept was
  // triggered from the card list or from inside the detail page.
  Future<void> _acceptRequest(BuildContext context, String docId,
      [Map<String, dynamic>? passedData]) async {
    try {
      debugPrint("🚀 Starting Accept Request...");

      // Always fetch fresh data from Firestore
      final docSnap = await FirebaseFirestore.instance
          .collection("demo_customer_form")
          .doc(docId)
          .get();

      if (!docSnap.exists) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Request no longer exists'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final customerData = docSnap.data() as Map<String, dynamic>;

      final fullLpm = await _generateLpm();

      final mainOrderId = fullLpm;
      final subOrderNo = "01";

      debugPrint("📋 Main Order ID: $mainOrderId");
      debugPrint("📦 Full LPM: $fullLpm");

      final designerData = _buildDesignerData(customerData);
      designerData['LpmAutoIncrement'] = fullLpm;

      final jobRef = FirebaseFirestore.instance.collection("jobs").doc(mainOrderId);
      final itemRef = jobRef.collection("items").doc(subOrderNo);

      await jobRef.set({
        "orderNo": fullLpm,
        "currentDepartment": "Designer",
        "visibleTo": ["Designer"],
        "status": "pending_designer_review",
        "acceptedAt": FieldValue.serverTimestamp(),
        "designer": {
          "submitted": false,
          "submittedAt": null,
          "submittedBy": "",
          "data": designerData,
        },
        "autoBending": {"submitted": false, "data": {}},
        "manualBending": {"submitted": false, "data": {}},
        "laserCutting": {"submitted": false, "data": {}},
        "emboss": {"submitted": false, "data": {}},
        "rubber": {"submitted": false, "data": {}},
        "account": {"submitted": false, "data": {}},
        "delivery": {"submitted": false, "data": {}},
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await itemRef.set({
        "fullLpm": fullLpm,
        "subOrderNo": subOrderNo,
        "currentDepartment": "Designer",
        "visibleTo": ["Designer"],
        "status": "InProgress",
        "designer": {
          "submitted": false,
          "submittedAt": null,
          "submittedBy": "",
          "data": designerData,
        },
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });

      await _incrementMonthlyCounter();

      await FirebaseFirestore.instance
          .collection("demo_customer_form")
          .doc(docId)
          .delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Request accepted! LPM: $mainOrderId'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint("❌ Error in _acceptRequest: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _rejectRequest(BuildContext context, String docId,
      Map<String, dynamic> customerData) async {
    try {
      await FirebaseFirestore.instance.collection("rejected_requests").add({
        ...customerData,
        "originalDocId": docId,
        "rejectedAt": FieldValue.serverTimestamp(),
        "status": "rejected",
      });

      await FirebaseFirestore.instance
          .collection("demo_customer_form")
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

  void _showAcceptDialog(BuildContext context, String docId, Map<String, dynamic> data) {
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
            Text("Job: ${data['jobName'] ?? 'N/A'}",
                style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            const Text(
              "A demo LPM number will be generated (demo1, demo2, ...).",
              style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _acceptRequest(context, docId);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text("Accept"),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, String docId, Map<String, dynamic> data) {
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
              style: TextStyle(fontWeight: FontWeight.w500, color: Colors.red),
            ),
            const SizedBox(height: 12),
            Text("Customer: ${data['partyName'] ?? 'N/A'}",
                style: const TextStyle(fontWeight: FontWeight.w500)),
            Text("Job: ${data['jobName'] ?? 'N/A'}",
                style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            const Text(
              "This action cannot be undone. The request will be saved in rejected records.",
              style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _rejectRequest(context, docId, data);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Reject"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text(
          'Customer Requests',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 18),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4A90D9),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF4A90D9),
          tabs: const [
            Tab(text: "Jobs"),
            Tab(text: "Quotations"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildJobsTab(),
          _buildQuotationsTab(),
        ],
      ),
    );
  }

  Widget _buildJobsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: searchController,
              onChanged: (value) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search by name, party, or job...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _customerRequestsStream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final latestDocs = snapshot.data!.docs;
              if (latestDocs.isNotEmpty) {
                _lastDoc = latestDocs.last;
              }
              final Map<String, QueryDocumentSnapshot> uniqueMap = {};
              for (var d in latestDocs) {
                uniqueMap[d.id] = d;
              }
              for (var d in _olderDocs) {
                uniqueMap.putIfAbsent(d.id, () => d);
              }
              final docs = uniqueMap.values.toList();

              if (docs.isEmpty) {
                return const Center(
                  child: Text("No customer requests available",
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                );
              }

              final query = searchController.text.trim().toLowerCase();

              final filteredDocs = docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final sendForQuotation = data["sendForQuotation"];
                if (sendForQuotation == true || sendForQuotation == "true") return false;
                final searchableText = [
                  data["partyName"], data["jobName"], data["machineName"],
                  data["deliveryAt"], data["flute"], data["cuttingRule"],
                  data["creasingRule"], data["materialToPunch"], data["priority"],
                ].join(" ").toLowerCase();
                if (query.isEmpty) return true;
                return searchableText.contains(query);
              }).toList();

              if (filteredDocs.isEmpty) {
                return const Center(
                  child: Text("No matching requests",
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                );
              }

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: filteredDocs.length + (_hasMore || _isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == filteredDocs.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: _isLoadingMore
                            ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                            : const SizedBox.shrink(),
                      ),
                    );
                  }
                  final data = filteredDocs[index].data() as Map<String, dynamic>;
                  final docId = filteredDocs[index].id;
                  return _buildCard(context, data, docId);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuotationsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("demo_customer_form")
          .orderBy("submittedAt", descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        // Change to:
        final docs = snapshot.data!.docs.where((d) {
          final data = d.data() as Map<String, dynamic>;
          final val = data["sendForQuotation"];
          if (!(val == true || val == "true")) return false;
          if (data["quotationSubmitted"] == true) return false;
          return true;
        }).toList();

        if (docs.isEmpty) {
          return const Center(
            child: Text("No quotations available",
                style: TextStyle(fontSize: 16, color: Colors.grey)),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final docId = docs[index].id;
            final partyName = data["partyName"] ?? "No Party";
            final jobName = data["jobName"] ?? "No Job";
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
                  onTap: () => context.push('/customer-quotation-detail/$docId'),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: const BoxDecoration(
                              color: Color(0xFFE3F0FF), shape: BoxShape.circle),
                          child: const Icon(Icons.description_outlined,
                              color: Color(0xFF4A90D9), size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(partyName.toString(),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                      color: Color(0xFF1A1A2E)),
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text("Job: $jobName",
                                  style: const TextStyle(
                                      color: Color(0xFF555555),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500),
                                  maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, Map<String, dynamic> data, String docId) {
    final partyName = data["partyName"] ?? "No Party";
    final jobName = data["jobName"] ?? "No Job";
    final priority = data["priority"] ?? "Normal";
    final deliveryAt = data["deliveryAt"] ?? "Not specified";
    final submittedAt = data["submittedAt"];

    String formattedDate = "N/A";
    if (submittedAt != null) {
      final dateTime = (submittedAt as Timestamp).toDate();
      formattedDate = "${dateTime.day}/${dateTime.month}/${dateTime.year}";
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
          onTap: () => context.push('/customer-request-detail/$docId'),
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
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: priorityColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: priorityColor, width: 1),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Job: $jobName",
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
                                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
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
                            style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
              SizedBox(
                height: 48,
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _showAcceptDialog(context, docId, data),
                        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(16)),
                        child: const Center(
                          child: Icon(Icons.check, color: Color(0xFF27AE60), size: 24),
                        ),
                      ),
                    ),
                    Container(width: 1, height: 48, color: Colors.grey.shade200),
                    Expanded(
                      child: InkWell(
                        onTap: () => _showRejectDialog(context, docId, data),
                        borderRadius: const BorderRadius.only(bottomRight: Radius.circular(16)),
                        child: const Center(
                          child: Icon(Icons.close, color: Color(0xFFE74C3C), size: 24),
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
      case "urgent": return const Color(0xFFE74C3C);
      case "high": return const Color(0xFFE74C3C);
      case "important": return const Color(0xFF27AE60);
      case "medium": return const Color(0xFFF39C12);
      case "emergency": return const Color(0xFFF39C12);
      case "low": return const Color(0xFF27AE60);
      default: return const Color(0xFF3498DB);
    }
  }

  String _getPriorityLabel(String priority) {
    switch (priority.toLowerCase()) {
      case "high": return "URGENT";
      case "urgent": return "URGENT";
      case "important": return "IMPORTANT";
      case "medium": return "EMERGENCY";
      case "emergency": return "EMERGENCY";
      case "low": return "IMPORTANT";
      default: return priority.toUpperCase();
    }
  }
}