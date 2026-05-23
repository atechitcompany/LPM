import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class QuotationDetailScreen extends StatelessWidget {
  final String quoteId;
  const QuotationDetailScreen({super.key, required this.quoteId});

  String _prettyValue(dynamic value) {
    if (value == null) return "-";
    if (value is bool) return value ? "Yes" : "No";
    if (value is List) return value.isEmpty ? "-" : value.join(", ");
    final str = value.toString().trim();
    return str.isEmpty ? "-" : str;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(quoteId)),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection("quotations")
            .doc(quoteId)
            .get(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.data!.exists) {
            return const Center(child: Text("Quotation not found"));
          }

          final data = snap.data!.data() as Map<String, dynamic>;
          final designerData =
          (data["designer"]?["data"] ?? {}) as Map<String, dynamic>;

          // Fields to show
          const showFields = [
            "PartyName", "particularJobName", "Orderby", "DeliveryAt",
            "Priority", "Remark", "PlyType", "Blade", "Creasing",
            "Perforation", "ZigZagBlade", "RubberType", "HoleType",
            "EmbossStatus", "StrippingType", "RubberFixingDone",
            "WhiteProfileRubber", "DesigningStatus",
          ];

          const labelOverrides = <String, String>{
            "PartyName": "Party Name",
            "particularJobName": "Job Name",
            "Orderby": "Order By",
            "DeliveryAt": "Delivery At",
            "PlyType": "Ply",
            "ZigZagBlade": "Zig Zag Blade",
            "RubberType": "Rubber",
            "HoleType": "Hole",
            "EmbossStatus": "Emboss",
            "StrippingType": "Stripping",
            "RubberFixingDone": "Rubber Fixing Done",
            "WhiteProfileRubber": "White Profile Rubber",
            "DesigningStatus": "Designing Status",
          };

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Quotation Details",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(quoteId),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFFCC80)),
                  ),
                  child: Text(
                    "Status: ${(data["status"] ?? "pending").toString().toUpperCase()}",
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE65100)),
                  ),
                ),

                const SizedBox(height: 20),

                // Info rows
                const Text(
                  "INFORMATION",
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                      letterSpacing: 1),
                ),
                const SizedBox(height: 12),

                ...showFields.map((key) {
                  final value = designerData[key];
                  if (value == null || value.toString().trim().isEmpty) {
                    return const SizedBox.shrink();
                  }
                  final label = labelOverrides[key] ??
                      key.replaceAllMapped(
                          RegExp(r'([A-Z])'), (m) => ' ${m[0]}').trim();

                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Text(label,
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 13)),
                            ),
                            Expanded(
                              flex: 6,
                              child: Text(
                                _prettyValue(value),
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(color: Colors.grey.shade300, height: 1),
                    ],
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }
}