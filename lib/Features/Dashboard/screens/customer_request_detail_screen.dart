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
        .collection('demo_customer_form')
        .doc(widget.docId)
        .get();
  }

  // ✅ LPM GENERATION - demo1, demo2, demo3... format
  Future<String> _generateLpm() async {
    try {
      final counterRef = FirebaseFirestore.instance
          .collection("counters")
          .doc("demo_counter");

      final snap = await counterRef.get().timeout(
        const Duration(seconds: 8),
        onTimeout: () => throw Exception("Firestore timeout — no internet?"),
      );

      int lastNo = 0;
      if (snap.exists) {
        lastNo = snap.data()?["lastNo"] ?? 0;
      } else {
        await counterRef.set({"lastNo": 0});
      }

      final newNo = lastNo + 1;
      final lpm = "demo$newNo";

      debugPrint("✅ LPM Generated: $lpm");
      return lpm;
    } catch (e) {
      debugPrint("❌ LPM Generation Error: $e");
      final fallback = "demo_temp_${DateTime.now().millisecondsSinceEpoch}";
      debugPrint("⚠️ Using fallback LPM: $fallback");
      return fallback;
    }
  }

  // ✅ INCREMENT DEMO COUNTER
  Future<void> _incrementDemoCounter() async {
    final counterRef = FirebaseFirestore.instance
        .collection("counters")
        .doc("demo_counter");

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snap = await transaction.get(counterRef);
      int lastNo = 0;
      if (snap.exists) {
        lastNo = snap.data()?["lastNo"] ?? 0;
      }
      transaction.set(counterRef, {"lastNo": lastNo + 1}, SetOptions(merge: true));
    });
  }

  // ✅ BUILD DESIGNER DATA from demo_customer_form fields
  Map<String, dynamic> _buildDesignerData(Map<String, dynamic> data) {
    return {
      "LpmAutoIncrement": "",
      "jobName": data["jobName"] ?? "",
      "machineName": data["machineName"] ?? "",
      "partyName": data["partyName"] ?? "",
      "deliveryAt": data["deliveryAt"] ?? "",
      "cuttingRule": data["cuttingRule"] ?? "",
      "creasingRule": data["creasingRule"] ?? "",
      "bladeWelding": data["bladeWelding"] ?? "",
      "boardCompressedThickness": data["boardCompressedThickness"] ?? "",
      "broaching": data["broaching"] ?? "",
      "centerNotch": data["centerNotch"] ?? "",
      "flute": data["flute"] ?? "",
      "materialToPunch": data["materialToPunch"] ?? "",
      "nicking": data["nicking"] ?? "",
      "partinex": data["partinex"] ?? "",
      "perforation": data["perforation"] ?? "",
      "plywoodSizeGriper": data["plywoodSizeGriper"] ?? "",
      "plywoodThickness": data["plywoodThickness"] ?? "",
      "rubberOrWithout": data["rubberOrWithout"] ?? "",
      "sanwitchDie": data["sanwitchDie"] ?? "",
      "strippingMaleFemale": data["strippingMaleFemale"] ?? "",
      "sendForQuotation": data["sendForQuotation"] ?? false,
      "DesigningStatus": "Pending",
      "Timestamp": DateTime.now().toIso8601String(),
    };
  }

  // ✅ ACCEPT LOGIC
  Future<void> _acceptRequest(Map<String, dynamic> customerData) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      debugPrint("🚀 Starting Accept Request...");

      final lpm = await _generateLpm();
      debugPrint("📋 LPM: $lpm");

      final designerData = _buildDesignerData(customerData);

      final jobRef = FirebaseFirestore.instance.collection("jobs").doc(lpm);

      await jobRef.set({
        "lpm": lpm,
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

      debugPrint("✅ Job document created: $lpm");

      await _incrementDemoCounter();
      debugPrint("✅ Demo counter incremented");

      await FirebaseFirestore.instance
          .collection("demo_customer_form")
          .doc(widget.docId)
          .delete();

      debugPrint("✅ Request deleted from demo_customer_form");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Request accepted! LPM: $lpm'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) context.pop();
      }
    } catch (e) {
      debugPrint("❌ Error in _acceptRequest: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // ✅ REJECT LOGIC
  Future<void> _rejectRequest(Map<String, dynamic> customerData) async {
    try {
      debugPrint("🚫 Starting Reject Request...");

      await FirebaseFirestore.instance.collection("rejected_requests").add({
        ...customerData,
        "originalDocId": widget.docId,
        "rejectedAt": FieldValue.serverTimestamp(),
        "status": "rejected",
      });

      await FirebaseFirestore.instance
          .collection("demo_customer_form")
          .doc(widget.docId)
          .delete();

      debugPrint("✅ Request rejected and deleted");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Request rejected and saved'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) context.pop();
      }
    } catch (e) {
      debugPrint("❌ Error in _rejectRequest: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

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
            Text("Party: ${customerData['partyName'] ?? 'N/A'}",
                style: const TextStyle(fontWeight: FontWeight.w500)),
            Text("Job: ${customerData['jobName'] ?? 'N/A'}",
                style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            const Text(
              "A unique LPM number will be generated automatically.",
              style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _acceptRequest(customerData);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text("Accept"),
          ),
        ],
      ),
    );
  }

  void _showRejectConfirmationDialog(Map<String, dynamic> customerData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Rejection"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("⚠️ Are you sure you want to reject this request?",
                style: TextStyle(fontWeight: FontWeight.w500, color: Colors.red)),
            const SizedBox(height: 12),
            Text("Party: ${customerData['partyName'] ?? 'N/A'}",
                style: const TextStyle(fontWeight: FontWeight.w500)),
            Text("Job: ${customerData['jobName'] ?? 'N/A'}",
                style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            const Text(
              "This action cannot be undone. The request will be saved in rejected records.",
              style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _rejectRequest(customerData);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
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
        title: const Text('Customer Request Details',
            style: TextStyle(fontWeight: FontWeight.bold)),
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
                // ✅ HEADER
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data["jobName"] ?? "No Job Name",
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              data["partyName"] ?? "No Party",
                              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),
                      if (data["sendForQuotation"] == true)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            border: Border.all(color: Colors.orange),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "Quotation",
                            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ✅ ACTION BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing ? null : () => _showRejectConfirmationDialog(data),
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
                        onPressed: _isProcessing ? null : () => _showConfirmationDialog(data),
                        icon: _isProcessing
                            ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                            : const Icon(Icons.check_circle),
                        label: Text(_isProcessing ? 'Processing...' : 'Accept'),
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

                // ✅ BASIC INFO
                _buildSectionHeader("Basic Information"),
                _buildDetailRow("Job Name", data["jobName"]),
                _buildDetailRow("Machine Name", data["machineName"]),
                _buildDetailRow("Party Name", data["partyName"]),
                _buildDetailRow("Delivery At", data["deliveryAt"]),
                _buildDetailRow("Send For Quotation",
                    data["sendForQuotation"] == true ? "Yes" : "No"),

                const SizedBox(height: 20),

                // ✅ DIE DETAILS
                _buildSectionHeader("Die Details"),
                _buildDetailRow("Cutting Rule", data["cuttingRule"]),
                _buildDetailRow("Creasing Rule", data["creasingRule"]),
                _buildDetailRow("Blade Welding", data["bladeWelding"]),
                _buildDetailRow("Broaching", data["broaching"]),
                _buildDetailRow("Center Notch", data["centerNotch"]),
                _buildDetailRow("Nicking", data["nicking"]),
                _buildDetailRow("Partinex", data["partinex"]),
                _buildDetailRow("Sanwitch Die", data["sanwitchDie"]),

                const SizedBox(height: 20),

                // ✅ MATERIAL
                _buildSectionHeader("Material Details"),
                _buildDetailRow("Material To Punch", data["materialToPunch"]),
                _buildDetailRow("Flute", data["flute"]),
                _buildDetailRow("Board Compressed Thickness",
                    data["boardCompressedThickness"]),
                _buildDetailRow("Plywood Thickness", data["plywoodThickness"]),
                _buildDetailRow("Plywood Size Griper", data["plywoodSizeGriper"]),

                const SizedBox(height: 20),

                // ✅ FINISHING
                _buildSectionHeader("Finishing"),
                _buildDetailRow("Perforation", data["perforation"]),
                _buildDetailRow("Rubber Or Without", data["rubberOrWithout"]),
                _buildDetailRow("Stripping Male Female", data["strippingMaleFemale"]),

                const SizedBox(height: 20),

                // ✅ METADATA
                _buildSectionHeader("Metadata"),
                _buildDetailRow("Submitted At", _formatTimestamp(data["submittedAt"])),
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
      child: Text(title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
            child: Text(label,
                style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            flex: 3,
            child: Text(displayValue.toString(),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return "N/A";
    try {
      final dateTime = (timestamp as Timestamp).toDate();
      return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return "Invalid date";
    }
  }
}