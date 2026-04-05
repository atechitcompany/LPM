import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:lightatech/core/session/session_manager.dart';
import 'package:lightatech/FormComponents/FlexibleToggle.dart';
import 'dart:convert';

class JobSummaryScreen extends StatefulWidget {
  final String lpm;
  const JobSummaryScreen({super.key, required this.lpm});

  @override
  State<JobSummaryScreen> createState() => _JobSummaryScreenState();
}

class _JobSummaryScreenState extends State<JobSummaryScreen> {
  late Future<DocumentSnapshot> _jobFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // 🚀 Har toggle click par screen ko live refresh karne ka function
  void _loadData() {
    setState(() {
      _jobFuture = FirebaseFirestore.instance.collection("jobs").doc(widget.lpm).get();
    });
  }

  String _normalizeDepartment(String dept) {
    switch (dept.toString().trim().toLowerCase()) {
      case "lasercut":
      case "lasercutting":
        return "LaserCutting";
      case "autobending":
        return "AutoBending";
      case "manualbending":
        return "ManualBending";
      case "designer":
        return "Designer";
      case "rubber":
        return "Rubber";
      case "emboss":
        return "Emboss";
      case "delivery":
        return "Delivery";
      default:
        return "Designer";
    }
  }

  String _prettyValue(dynamic value) {
    if (value == null) return "-";
    if (value is bool) return value ? "Yes" : "No";
    if (value is List) {
      if (value.isEmpty) return "-";
      return value.join(", ");
    }
    if (value is Map) {
      if (value.isEmpty) return "-";
      return value.entries.map((e) => "${e.key}: ${e.value}").join(", ");
    }
    final str = value.toString().trim();
    return str.isEmpty ? "-" : str;
  }

  static const Map<String, String> departmentEditRoute = {
    "Designer": "/jobform/designer-1",
    "AutoBending": "/jobform/autobending",
    "ManualBending": "/jobform/manualbending",
    "LaserCutting": "/jobform/laser",
    "Emboss": "/jobform/emboss",
    "Rubber": "/jobform/rubber",
    "Account": "/jobform/account1",
    "Delivery": "/jobform/delivery",
  };

  static const Map<String, String> departmentFirestoreKey = {
    "Designer": "designer",
    "AutoBending": "autoBending",
    "ManualBending": "manualBending",
    "LaserCutting": "laserCutting",
    "Emboss": "emboss",
    "Rubber": "rubber",
    "Account": "account",
    "Delivery": "delivery",
  };

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
        future: _jobFuture,
        builder: (context, snap) {
          if (!snap.hasData) {
            return Scaffold(
              appBar: AppBar(title: const Text("Job Summary", style: TextStyle(color: Colors.black)), backgroundColor: Colors.yellow),
              body: const Center(child: CircularProgressIndicator(color: Colors.yellow)),
            );
          }

          if (!snap.data!.exists) {
            return Scaffold(
              appBar: AppBar(title: const Text("Job Summary", style: TextStyle(color: Colors.black)), backgroundColor: Colors.yellow),
              body: const Center(child: Text("Job not found")),
            );
          }

          final data = snap.data!.data() as Map<String, dynamic>;
          final rawDept = SessionManager.getDepartment() ?? "";
          final dept = _normalizeDepartment(rawDept);

          final deptKey = departmentFirestoreKey[dept];
          final Map<String, dynamic> summaryData = Map<String, dynamic>.from(data[deptKey]?["data"] ?? {});

          void handleEditForm() {
            final route = departmentEditRoute[dept];
            if (route == null) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No form for $dept")));
              return;
            }
            final dataJson = jsonEncode(summaryData);
            context.push("$route?lpm=${widget.lpm}&mode=edit&data=$dataJson");
          }

          return Scaffold(
            backgroundColor: Colors.grey.shade50,
            appBar: AppBar(
              title: const Text("Job Summary", style: TextStyle(color: Colors.black)),
              backgroundColor: Colors.yellow,
              iconTheme: const IconThemeData(color: Colors.black),
              elevation: 0,
            ),

            floatingActionButton: dept == "Designer"
                ? FloatingActionButton(
              onPressed: handleEditForm,
              backgroundColor: Colors.yellow.shade700,
              elevation: 4,
              child: const Icon(Icons.edit, color: Colors.black),
            )
                : null,

            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= HEADER =================
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "$dept Details",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(8)),
                            child: Text(widget.lpm, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ================= AMAZON STYLE TRACKER =================
                  _sectionTitle("Live Job Status"),
                  _buildAmazonTracker(data),
                  const SizedBox(height: 24),

                  // ================= 🚀 NEW: MULTIPLE TOGGLES (Only for Designer) =================
                  if (dept == "Designer") ...[
                    _sectionTitle("⚡ Department Controls (Live Update)"),
                    _buildMultipleTogglesCard(data),
                    const SizedBox(height: 24),
                  ],

                  // ================= FORM SUMMARY =================
                  _sectionTitle("Information"),

                  if (dept == "Designer")
                    _buildDesignerSpecificView(data)
                  else
                    _card(summaryData.entries.map((e) => _row(e.key, _prettyValue(e.value))).toList()),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.yellow.shade700,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                      ),
                      onPressed: handleEditForm,
                      child: const Text("Edit Full Form", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          );
        }
    );
  }

  // ================= 🚀 MULTIPLE TOGGLES LOGIC =================
  Widget _buildMultipleTogglesCard(Map<String, dynamic> jobData) {
    final d = Map<String, dynamic>.from(jobData["designer"]?["data"] ?? {});
    bool reqRubber = (d["ReqRubber"] ?? "").toString().trim().toUpperCase() == "YES";
    bool reqEmboss = (d["ReqEmboss"] ?? "").toString().trim().toUpperCase() == "YES";

    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.yellow.shade700, width: 1.5)
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Toggle to update Stepper & Database instantly:", style: TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 20),

            _buildSingleToggle("Designing", "designer", "Designing", jobData),
            const SizedBox(height: 14),
            _buildSingleToggle("Laser Cutting", "laserCutting", "LaserCutting", jobData),
            const SizedBox(height: 14),
            _buildSingleToggle("Auto Bending", "autoBending", "AutoBending", jobData),
            const SizedBox(height: 14),
            _buildSingleToggle("Manual Bending", "manualBending", "ManualBending", jobData),

            if (reqRubber) ...[
              const SizedBox(height: 14),
              _buildSingleToggle("Rubber", "rubber", "Rubber", jobData),
            ],
            if (reqEmboss) ...[
              const SizedBox(height: 14),
              _buildSingleToggle("Emboss", "emboss", "Emboss", jobData),
            ],

            const SizedBox(height: 14),
            _buildSingleToggle("Dispatch / Delivery", "delivery", "Delivery", jobData),
          ],
        ),
      ),
    );
  }

  // Individual Toggle Widget Builder
  Widget _buildSingleToggle(String label, String dbKey, String prefix, Map<String, dynamic> jobData) {
    bool isDone = false;

    // Check Current Status from Database
    if (dbKey == "designer") {
      isDone = jobData["designer"]?["submitted"] == true || jobData["designer"]?["data"]?["DesigningStatus"]?.toString().toLowerCase() == "done";
    } else {
      isDone = jobData[dbKey]?["data"]?["${prefix}Status"]?.toString().toLowerCase() == "done" || jobData[dbKey]?["submitted"] == true;
    }

    return FlexibleToggle(
      label: label,
      inactiveText: "Pending",
      activeText: "Done",
      initialValue: isDone,
      onChanged: (val) {
        _updateDeptStatusLive(label, dbKey, prefix, val);
      },
    );
  }

  // Instantly Update Firebase and Refresh UI
  Future<void> _updateDeptStatusLive(String label, String dbKey, String prefix, bool isDone) async {
    String userName = SessionManager.getUserName() ?? "Current User";
    String formattedTime = "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} at ${TimeOfDay.now().format(context)}";

    final updateData = {
      dbKey: {
        "submitted": isDone,
        "data": {
          "${prefix}Status": isDone ? "Done" : "Pending",
          "${prefix}CreatedByName": isDone ? userName : "",
          "${prefix}CreatedByTimestamp": isDone ? formattedTime : "",
        }
      },
      "updatedAt": FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance.collection("jobs").doc(widget.lpm).set(updateData, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("$label marked as ${isDone ? 'Done' : 'Pending'}!"),
              backgroundColor: isDone ? Colors.green : Colors.orange,
              duration: const Duration(seconds: 1), // Fast feedback
            )
        );
        _loadData(); // 🚀 Yeh UI aur Stepper ko live refresh kar dega!
      }
    } catch(e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
      }
    }
  }


  // ================= UI HELPERS =================
  Widget _sectionTitle(String t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        t.toUpperCase(),
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(padding: const EdgeInsets.all(16), child: Column(children: children)),
    );
  }

  Widget _row(String label, dynamic value) {
    final text = (value == null || value.toString().trim().isEmpty || value.toString() == "-") ? "Not Provided" : value.toString();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 4, child: Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade700, fontSize: 14))),
          Expanded(flex: 6, child: Text(text, style: TextStyle(color: text == "Not Provided" ? Colors.grey.shade400 : Colors.black87, fontWeight: FontWeight.w500, fontSize: 14))),
        ],
      ),
    );
  }

  // ================= EXACT LIVE TRACKER LOGIC =================
  Widget _buildAmazonTracker(Map<String, dynamic> jobData) {
    final d = Map<String, dynamic>.from(jobData["designer"]?["data"] ?? {});
    bool reqRubber = (d["ReqRubber"] ?? "").toString().trim().toUpperCase() == "YES";
    bool reqEmboss = (d["ReqEmboss"] ?? "").toString().trim().toUpperCase() == "YES";

    List<String> flow = ["Designer", "LaserCutting", "AutoBending", "ManualBending"];
    List<String> displayFlow = ["Design", "Laser", "AutoBend", "Manual"];

    if (reqRubber) { flow.add("Rubber"); displayFlow.add("Rubber"); }
    if (reqEmboss) { flow.add("Emboss"); displayFlow.add("Emboss"); }

    flow.add("Delivery"); displayFlow.add("Dispatch");

    bool isLaserDone = jobData["laserCutting"]?["data"]?["LaserCuttingStatus"]?.toString().toLowerCase() == "done";
    bool isAutoBendDone = jobData["autoBending"]?["data"]?["AutoBendingStatus"]?.toString().toLowerCase() == "done";
    bool isManualBendDone = jobData["manualBending"]?["data"]?["ManualBendingStatus"]?.toString().toLowerCase() == "done";
    bool isRubberDone = jobData["rubber"]?["data"]?["RubberStatus"]?.toString().toLowerCase() == "done";
    bool isEmbossDone = jobData["emboss"]?["data"]?["EmbossStatus"]?.toString().toLowerCase() == "done";
    bool isDeliveryDone = jobData["delivery"]?["data"]?["DeliveryStatus"]?.toString().toLowerCase() == "done";

    int currentIndex = 0;

    // Backward Search: Piche se dhoondho ki aakhri kahan Done hua hai
    for (int i = flow.length - 1; i >= 0; i--) {
      String currentCheckingDept = flow[i];
      bool isDone = false;

      if (currentCheckingDept == "Designer") {
        isDone = jobData["designer"]?["submitted"] == true || jobData["designer"]?["data"]?["DesigningStatus"]?.toString().toLowerCase() == "done";
      } else if (currentCheckingDept == "LaserCutting") isDone = isLaserDone;
      else if (currentCheckingDept == "AutoBending") isDone = isAutoBendDone;
      else if (currentCheckingDept == "ManualBending") isDone = isManualBendDone;
      else if (currentCheckingDept == "Rubber") isDone = isRubberDone;
      else if (currentCheckingDept == "Emboss") isDone = isEmbossDone;
      else if (currentCheckingDept == "Delivery") isDone = isDeliveryDone;

      if (isDone) {
        currentIndex = i + 1; // Jo done ho gaya usse agla step active hoga
        break;
      }
    }

    bool isFullyComplete = false;
    if (currentIndex >= flow.length || isDeliveryDone) {
      currentIndex = flow.length - 1;
      isFullyComplete = true;
    }

    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(flow.length, (index) {
              bool isPast = index < currentIndex || (isFullyComplete && index == flow.length - 1);
              bool isActive = index == currentIndex && !isFullyComplete;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 65,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: isActive ? Colors.orange : (isPast ? Colors.green : Colors.grey.shade300),
                          child: Icon(
                            isPast ? Icons.check : (isActive ? Icons.autorenew : Icons.circle),
                            size: 16,
                            color: isActive || isPast ? Colors.white : Colors.grey.shade400,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(displayFlow[index], textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: isActive ? FontWeight.bold : FontWeight.w500, color: isActive ? Colors.orange : (isPast ? Colors.green : Colors.grey)))
                      ],
                    ),
                  ),
                  if (index != flow.length - 1)
                    Container(margin: const EdgeInsets.only(top: 13), width: 25, height: 2, color: isPast ? Colors.green : Colors.grey.shade300),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  // ================= DESIGNER SPECIFIC VIEW =================
  Widget _buildDesignerSpecificView(Map<String, dynamic> allData) {
    final d = Map<String, dynamic>.from(allData["designer"]?["data"] ?? {});
    final laser = Map<String, dynamic>.from(allData["laserCutting"]?["data"] ?? {});
    final autoBending = Map<String, dynamic>.from(allData["autoBending"]?["data"] ?? {});
    final manualBending = Map<String, dynamic>.from(allData["manualBending"]?["data"] ?? {});
    final delivery = Map<String, dynamic>.from(allData["delivery"]?["data"] ?? {});

    String val(dynamic v) {
      if (v == null) return "Not Provided";
      if (v is bool) return v ? "Yes" : "No";
      final str = v.toString().trim();
      return str.isEmpty ? "Not Provided" : str;
    }

    return _card([
      _row("Party Name", val(d["PartyName"])),
      _row("Particular Job Name", val(d["ParticularJobName"] ?? d["particularJobName"])),
      _row("Priority", val(d["Priority"])),
      _row("Remark", val(d["Remark"])),
      _row("Delivery At", val(d["DeliveryAt"])),
      const Divider(),
      _row("Ply", val(d["PlyType"])),
      _row("Blade", val(d["Blade"])),
      _row("Creasing", val(d["Creasing"])),
      _row("Perforation", val(d["Perforation"])),
      _row("Zigzag Blade", val(d["ZigZagBlade"])),
      _row("Rubber", val(d["RubberType"])),
      _row("White Profile Rubber", val(d["WhiteProfileRubber"])),
      _row("Hole", val(d["HoleType"])),
      _row("Emboss", val(d["MaleEmbossType"] ?? d["EmbossStatus"])),
      _row("Stripping", val(d["StrippingType"])),
      const Divider(),
      _row("Manual Bending By", val(manualBending["ManualBendingCreatedByName"])),
      _row("Auto Bending By", val(autoBending["AutoBendingCreatedByName"])),
      _row("Auto Creasing By", val(autoBending["AutoCreasingCreatedByName"])),
      _row("Laser Cutting By", val(laser["LaserCuttingCreatedByName"])),
      _row("Delivery", val(delivery["DeliveryStatus"] ?? delivery["DeliveryCreatedByName"])),
      const Divider(),
      _row("Micro Serration Half Cut 23.60", val(d["MicroSerrationHalfCut"] ?? d["microSerrationHalfCut"] ?? d["MicroSerrationHalfCut2360"] ?? d["Micro Serration Half Cut 23.60"])),
      _row("Micro Serration Creasing 23.25", val(d["MicroSerrationCreasing"] ?? d["microSerrationCreasing"] ?? d["MicroSerrationCreasing2325"] ?? d["Micro Serration Creasing 23.25"])),
    ]);
  }
}