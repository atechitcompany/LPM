import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomerRequestDetailScreen extends StatefulWidget {
  final String docId;

  const CustomerRequestDetailScreen({
    super.key,
    required this.docId,
  });

  @override
  State<CustomerRequestDetailScreen> createState() =>
      _CustomerRequestDetailScreenState();
}

class _CustomerRequestDetailScreenState
    extends State<CustomerRequestDetailScreen> {
  late Future<DocumentSnapshot> _docFuture;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _docFuture = FirebaseFirestore.instance
        .collection('customer_requests')
        .doc(widget.docId)
        .get();
  }

  // ✅ SHARED LPM GENERATION - Same as customer_requests_screen.dart and new_form.dart
  Future<String> _generateLpm() async {
    try {
      final now = DateTime.now();
      final month = now.month.toString().padLeft(2, '0');
      final year = (now.year % 100).toString().padLeft(2, '0');
      final counterDocId = "${now.year}_$month";

      debugPrint("⏳ Generating LPM... counterDoc=$counterDocId");

      final counterRef = FirebaseFirestore.instance
          .collection("counters")
          .doc(counterDocId);

      // ✅ Set a timeout so it doesn't hang forever if offline
      final snap = await counterRef.get().timeout(
        const Duration(seconds: 8),
        onTimeout: () => throw Exception("Firestore timeout — no internet?"),
      );

      int lastOrderNo = 0;
      if (snap.exists) {
        lastOrderNo = snap.data()?["lastOrderNo"] ?? 0;
      } else {
        await counterRef.set({"lastOrderNo": 0});
      }

      final newOrderNo = (lastOrderNo + 1).toString().padLeft(5, '0');
      final fullLpm = "LPM-$newOrderNo-$month-$year-01";

      debugPrint("✅ LPM Generated: $fullLpm");
      return fullLpm;

    } catch (e) {
      debugPrint("❌ LPM Generation Error: $e");
      // ✅ Fallback: generate a temporary LPM from timestamp
      final now = DateTime.now();
      final month = now.month.toString().padLeft(2, '0');
      final year = (now.year % 100).toString().padLeft(2, '0');
      final tempNo = now.millisecondsSinceEpoch.toString().substring(7);
      final fallbackLpm = "LPM-TEMP$tempNo-$month-$year-01";
      debugPrint("⚠️ Using fallback LPM: $fallbackLpm");
      return fallbackLpm;
    }
  }

  // ✅ INCREMENT MONTHLY COUNTER - Same as customer_requests_screen.dart and new_form.dart
  Future<void> _incrementMonthlyCounter() async {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final counterDocId = "${now.year}_$month";

    final counterRef =
    FirebaseFirestore.instance.collection("counters").doc(counterDocId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snap = await transaction.get(counterRef);

      int lastOrderNo = 0;

      if (snap.exists) {
        lastOrderNo = snap.data()?["lastOrderNo"] ?? 0;
      }

      transaction.set(
        counterRef,
        {"lastOrderNo": lastOrderNo + 1},
        SetOptions(merge: true),
      );
    });
  }

  // ✅ BUILD DESIGNER DATA - Maps customer request data to designer format
  // ✅ FIXED: Handles both lowercase and uppercase keys from source data
  Map<String, dynamic> _buildDesignerData(Map<String, dynamic> customerData) {
    // Helper function to get value with case-insensitive fallback
    T? _getValue<T>(String camelCase, String pascalCase) {
      final camel = customerData[camelCase];
      if (camel != null) return camel as T?;
      return customerData[pascalCase] as T?;
    }

    return {
      "LpmAutoIncrement": "", // Will be set during submission
      "BuyerOrderNo": _getValue("buyerOrderNo", "BuyerOrderNo") ?? "",
      "DeliveryAt": _getValue("deliveryAt", "DeliveryAt") ?? "",
      "Orderby": _getValue("orderBy", "Orderby") ?? "",
      "Remark": _getValue("remark", "Remark") ?? "NO REMARK",
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
      "CapsuleType": _getValue("capsuleType", "CapsuleType") ?? "",
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
      "X": _getValue("x", "X") ?? "",
      "Y": _getValue("y", "Y") ?? "",
      "XYSize": _getValue("xySize", "XYSize") ?? "",
      "FemaleEmbossType": "No",
      "FemaleRate": "",
      "X2": _getValue("x2", "X2") ?? "",  // ✅ FIX: Now handles both cases
      "Y2": _getValue("y2", "Y2") ?? "",  // ✅ FIX: Now handles both cases
      "XY2Size": _getValue("xy2Size", "XY2Size") ?? "",
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
      "PartyName": _getValue("partyName", "PartyName") ?? "",
      "particularJobName": _getValue("particularJobName", "ParticularJobName") ?? "",
      "Priority": _getValue("priority", "Priority") ?? "Normal",
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

  // ✅ ACCEPT LOGIC — UNIFIED WITH customer_requests_screen.dart and new_form.dart
  Future<void> _acceptRequest(Map<String, dynamic> customerData) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    try {
      debugPrint("🚀 Starting Accept Request...");

      // Step 1: Generate LPM (UNIFIED FORMAT)
      final fullLpm = await _generateLpm();

      // Parse LPM to extract components
      final parts = fullLpm.split("-");
      final orderNo = parts[1];
      final month = parts[2];
      final year = parts[3];
      final subOrderNo = parts[4];
      final mainOrderId = "LPM-$orderNo-$month-$year";

      debugPrint("📋 Main Order ID: $mainOrderId");
      debugPrint("📦 Full LPM: $fullLpm");

      // Step 2: Build designer data from customer request
      final designerData = _buildDesignerData(customerData);

      // Step 3: Create job document in jobs collection
      final jobRef = FirebaseFirestore.instance
          .collection("jobs")
          .doc(mainOrderId);

      final itemRef = jobRef.collection("items").doc(subOrderNo);

      // ✅ Create main order document with proper nested structure
      await jobRef.set({
        "orderNo": orderNo,
        "month": month,
        "year": year,
        "currentDepartment": "Designer",
        "visibleTo": ["Designer"],
        "status": "pending_designer_review",
        "acceptedAt": FieldValue.serverTimestamp(),

        // ✅ All departments initialized
        "designer": {
          "submitted": false,
          "submittedAt": null,
          "submittedBy": "",
          "data": designerData,
        },
        "autoBending": {
          "submitted": false,
          "data": {},
        },
        "manualBending": {
          "submitted": false,
          "data": {},
        },
        "laserCutting": {
          "submitted": false,
          "data": {},
        },
        "emboss": {
          "submitted": false,
          "data": {},
        },
        "rubber": {
          "submitted": false,
          "data": {},
        },
        "account": {
          "submitted": false,
          "data": {},
        },
        "delivery": {
          "submitted": false,
          "data": {},
        },

        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      debugPrint("✅ Main order document created in jobs collection");

      // ✅ Create sub-order item document
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

      debugPrint("✅ Sub-order item document created in jobs/{mainOrderId}/items collection");

      // Step 4: Increment monthly counter
      await _incrementMonthlyCounter();
      debugPrint("✅ Monthly counter incremented");

      // Step 5: Delete from customer_requests collection
      await FirebaseFirestore.instance
          .collection("customer_requests")
          .doc(widget.docId)
          .delete();

      debugPrint("✅ Request deleted from customer_requests collection");

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Request accepted! LPM: $mainOrderId'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );

        // Auto-close after 2 seconds
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          context.pop();
        }
      }
    } catch (e) {
      debugPrint("❌ Error in _acceptRequest: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  // ✅ REJECT LOGIC — Saves to "rejected_requests" collection and deletes from customer_requests
  Future<void> _rejectRequest(Map<String, dynamic> customerData) async {
    try {
      debugPrint("🚫 Starting Reject Request...");

      // Step 1: Save full customer data to rejected_requests collection
      await FirebaseFirestore.instance
          .collection("rejected_requests")
          .add({
        ...customerData,
        "originalDocId": widget.docId,
        "rejectedAt": FieldValue.serverTimestamp(),
        "status": "rejected",
      });

      debugPrint("✅ Request saved to rejected_requests collection");

      // Step 2: Delete from customer_requests collection
      await FirebaseFirestore.instance
          .collection("customer_requests")
          .doc(widget.docId)
          .delete();

      debugPrint("✅ Request deleted from customer_requests collection");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Request rejected and saved'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          context.pop();
        }
      }
    } catch (e) {
      debugPrint("❌ Error in _rejectRequest: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ✅ Show confirmation dialog for Accept
  void _showConfirmationDialog(Map<String, dynamic> customerData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Accept"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Are you sure you want to accept this request?"),
            const SizedBox(height: 12),
            Text(
              "Customer: ${customerData['partyName'] ?? 'N/A'}",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              "Job: ${customerData['particularJobName'] ?? 'N/A'}",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            const Text(
              "A unique LPM number will be generated automatically.",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _acceptRequest(customerData);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text("Accept"),
          ),
        ],
      ),
    );
  }

  // ✅ Show confirmation dialog for Reject
  void _showRejectConfirmationDialog(Map<String, dynamic> customerData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Rejection"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "⚠️ Are you sure you want to reject this request?",
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Customer: ${customerData['partyName'] ?? 'N/A'}",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              "Job: ${customerData['particularJobName'] ?? 'N/A'}",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            const Text(
              "This action cannot be undone. The request will be saved in rejected records.",
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _rejectRequest({});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Reject"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade50,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Customer Request Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _docFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Request not found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ HEADER SECTION
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data["name"] ?? "No Name",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  data["partyName"] ?? "No Party",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getPriorityColor(data["priority"])
                                  .withOpacity(0.2),
                              border: Border.all(
                                color: _getPriorityColor(data["priority"]),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              data["priority"] ?? "Normal",
                              style: TextStyle(
                                color: _getPriorityColor(data["priority"]),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ✅ ACTION BUTTONS - REJECT & ACCEPT (REJECT LEFT, ACCEPT RIGHT)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing
                            ? null
                            : () {
                          _showRejectConfirmationDialog(data);
                        },
                        icon: const Icon(Icons.cancel),
                        label: const Text('Reject'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing
                            ? null
                            : () {
                          _showConfirmationDialog(data);
                        },
                        icon: _isProcessing
                            ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                            : const Icon(Icons.check_circle),
                        label: Text(
                            _isProcessing ? 'Processing...' : 'Accept'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ✅ FORM 1 - BASIC INFO
                _buildSectionHeader("📋 Basic Information"),
                _buildDetailRow("Name", data["name"]),
                _buildDetailRow("Party Name", data["partyName"]),
                _buildDetailRow("Particular Job Name",
                    data["particularJobName"]),
                _buildDetailRow("Order By", data["orderBy"]),
                _buildDetailRow("Delivery At", data["deliveryAt"]),
                _buildDetailRow("Priority", data["priority"]),
                _buildDetailRow("Remark", data["remark"]),

                const SizedBox(height: 20),

                // ✅ FORM 2 - DESIGNING DETAILS
                _buildSectionHeader("🎨 Designing Details"),
                _buildDetailRow("Designing Status", data["designingStatus"]),
                _buildDetailRow("Designed By", data["designedBy"]),
                _buildDetailRow("Ply Type", data["plyType"]),
                _buildDetailRow("Ply Selected By", data["plySelectedBy"]),

                const SizedBox(height: 20),

                // ✅ FORM 3 - BLADE & CREASING
                _buildSectionHeader("🔪 Blade & Creasing"),
                _buildDetailRow("Blade", data["blade"]),
                _buildDetailRow("Blade Selected By", data["bladeSelectedBy"]),
                _buildDetailRow("Creasing", data["creasing"]),
                _buildDetailRow(
                    "Creasing Selected By", data["creasingSelectedBy"]),
                _buildDetailRow("Capsule Type", data["capsuleType"]),
                _buildDetailRow("Unknown", data["unknown"]),

                const SizedBox(height: 20),

                // ✅ FORM 4 - PERFORATION & EMBOSS
                _buildSectionHeader("⚙️ Perforation & Embossing"),
                _buildDetailRow("Perforation", data["perforation"]),
                _buildDetailRow(
                    "Perforation Selected By", data["perforationSelectedBy"]),
                _buildDetailRow("Zig Zag Blade", data["zigZagBlade"]),
                _buildDetailRow(
                    "Zig Zag Blade Selected By", data["zigZagBladeSelectedBy"]),
                _buildDetailRow("Rubber Type", data["rubberType"]),
                _buildDetailRow("Rubber Selected By", data["rubberSelectedBy"]),
                _buildDetailRow("Hole Type", data["holeType"]),
                _buildDetailRow("Hole Selected By", data["holeSelectedBy"]),
                _buildDetailRow("Emboss Status", data["embossStatus"]),
                _buildDetailRow("Emboss Pcs", data["embossPcs"]),

                const SizedBox(height: 20),

                // ✅ FORM 5 - EMBOSS COORDINATES
                _buildSectionHeader("📍 Emboss Coordinates"),
                _buildDetailRow("Male Emboss Type", data["maleEmbossType"]),
                _buildDetailRow(
                    "Female Emboss Type", data["femaleEmbossType"]),
                _buildDetailRow("X", data["x"]),
                _buildDetailRow("Y", data["y"]),
                _buildDetailRow("X2", data["x2"]),  // ✅ Shows lowercase from source
                _buildDetailRow("Y2", data["y2"]),  // ✅ Shows lowercase from source

                const SizedBox(height: 20),

                // ✅ FORM 6 - FINISHING
                _buildSectionHeader("✨ Finishing"),
                _buildDetailRow("Stripping Type", data["strippingType"]),
                _buildDetailRow(
                    "Laser Cutting Status", data["laserCuttingStatus"]),
                _buildDetailRow("Rubber Fixing Done", data["rubberFixingDone"]),
                _buildDetailRow(
                    "White Profile Rubber", data["whiteProfileRubber"]),

                const SizedBox(height: 20),

                // ✅ METADATA
                _buildSectionHeader("📅 Metadata"),
                _buildDetailRow(
                  "Created At",
                  _formatTimestamp(data["createdAt"]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic value) {
    final displayValue =
    value == null || value.toString().isEmpty ? "Not specified" : value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              displayValue.toString(),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case "high":
        return Colors.red;
      case "medium":
        return Colors.orange;
      case "low":
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return "N/A";
    try {
      final dateTime = (timestamp as Timestamp).toDate();
      return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
    } catch (e) {
      return "Invalid date";
    }
  }
}