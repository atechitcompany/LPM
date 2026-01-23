import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class JobSummaryScreen extends StatelessWidget {
  final String lpm;

  const JobSummaryScreen({
    super.key,
    required this.lpm,
  });

  // ✅ Helper UI widget for "Label : Value"
  Widget _field(String label, dynamic value) {
    final textValue = (value ?? "").toString().trim();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        "$label : ${textValue.isEmpty ? "-" : textValue}",
        style: const TextStyle(
          fontSize: 14,
          height: 1.4,
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final query = FirebaseFirestore.instance
        .collection("jobs")
        .where("LpmAutoIncrement", isEqualTo: lpm)
        .limit(1);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Job Summary - $lpm"),
        backgroundColor: Colors.yellow,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: query.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Error loading job summary"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text("No job found for LPM: $lpm"),
            );
          }

          final data = snapshot.data!.docs.first.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Designer Form Summary",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // ✅ Only Designer Form fields
                  _field("LPM No", data["LpmAutoIncrement"]),
                  _field("Party Name", data["PartyName"]),
                  _field("Designer Created By", data["DesignerCreatedBy"]),
                  _field("Delivery At", data["DeliveryAt"]),
                  _field("Order By", data["Orderby"]),
                  _field("Particular Job Name", data["ParticularJobName"]),
                  _field("Priority", data["Priority"]),
                  _field("Remark", data["Remark"]),

                  const Divider(height: 25),

                  // ✅ Designing / Reports
                  _field("Designing Status", data["DesigningStatus"]),
                  _field("Designed By", data["DesignedBy"]),
                  _field("Ply Type", data["PlyType"]),
                  _field("Ply Selected By", data["PlySelectedBy"]),

                  const Divider(height: 25),

                  // ✅ Blade / Creasing
                  _field("Blade", data["Blade"]),
                  _field("Blade Selected By", data["BladeSelectedBy"]),
                  _field("Creasing", data["Creasing"]),
                  _field("Creasing Selected By", data["CreasingSelectedBy"]),

                  const Divider(height: 25),

                  // ✅ Page 4 items (Perforation etc)
                  _field("Perforation", data["Perforation"]),
                  _field("Perforation Selected By", data["PerforationSelectedBy"]),

                  _field("Zig Zag Blade", data["ZigZagBlade"]),
                  _field("Zig Zag Blade Selected By", data["ZigZagBladeSelectedBy"]),

                  _field("Rubber Type", data["RubberType"]),
                  _field("Rubber Selected By", data["RubberSelectedBy"]),

                  _field("Hole Type", data["HoleType"]),
                  _field("Hole Selected By", data["HoleSelectedBy"]),

                  const Divider(height: 25),

                  // ✅ Page 6 items
                  _field("Stripping", data["StrippingType"]),
                  _field("Laser Cutting Status", data["LaserCuttingStatus"]),
                  _field("Rubber Fixing Done", data["RubberFixingDone"]),
                  _field("White Profile Rubber", data["WhiteProfileRubber"]),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
