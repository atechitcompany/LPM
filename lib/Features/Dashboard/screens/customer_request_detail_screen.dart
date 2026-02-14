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

  @override
  void initState() {
    super.initState();
    _docFuture = FirebaseFirestore.instance
        .collection('customers')
        .doc(widget.docId)
        .get();
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
                _buildDetailRow("X2", data["x2"]),
                _buildDetailRow("Y2", data["y2"]),

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

                const SizedBox(height: 30),

                // ✅ ACTION BUTTONS
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                              Text('This feature will be added soon!'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Approved!'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Approve'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
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