import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../new_form_scope.dart';
import 'package:lightatech/FormComponents/AddableSearchDropdown.dart';
import 'package:lightatech/FormComponents/FlexibleToggle.dart';
import 'package:lightatech/FormComponents/TextInput.dart'; // 🟢 Added your TextInput component!
import 'package:lightatech/core/session/session_manager.dart';
import 'dart:convert';

class DesignerPage6 extends StatefulWidget {
  const DesignerPage6({super.key});

  @override
  State<DesignerPage6> createState() => _DesignerPage6State();
}

class _DesignerPage6State extends State<DesignerPage6> {
  bool isSubmitting = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    if (NewFormScope.of(context).mode == "edit") _loadDesignerData();
  }

  Future<void> _loadDesignerData() async {
    final form = NewFormScope.of(context);
    final uri = GoRouterState.of(context).uri;
    final dataJson = uri.queryParameters['data'];
    final lpmParam = uri.queryParameters['lpm'];

    if (dataJson != null && dataJson.isNotEmpty) {
      try {
        final decodedData = jsonDecode(dataJson) as Map<String, dynamic>;
        form.StrippingType.text = decodedData["StrippingType"] ?? "No";
        form.LaserCuttingStatus.text = decodedData["LaserCuttingStatus"] ?? "Pending";
        form.RubberFixingDone.text = decodedData["RubberFixingDone"] ?? "No";
        form.WhiteProfileRubber.text = decodedData["WhiteProfileRubber"] ?? "No";
        form.DesigningStatus.text = decodedData["DesigningStatus"] ?? "Pending";
        form.DesignedBy.text = decodedData["DesignedBy"] ?? "";
        form.DesignerCreatedBy.text = decodedData["DesignerCreatedBy"] ?? "";
      } catch (e) {
        debugPrint("❌ Error decoding data: $e");
      }
    } else if (lpmParam != null && lpmParam.isNotEmpty) {
      try {
        final snap = await FirebaseFirestore.instance.collection("jobs").doc(lpmParam).get();
        if (snap.exists) {
          final decodedData = Map<String, dynamic>.from(snap.data()?["designer"]?["data"] ?? {});
          setState(() {
            form.StrippingType.text = decodedData["StrippingType"] ?? "No";
            form.LaserCuttingStatus.text = decodedData["LaserCuttingStatus"] ?? "Pending";
            form.RubberFixingDone.text = decodedData["RubberFixingDone"] ?? "No";
            form.WhiteProfileRubber.text = decodedData["WhiteProfileRubber"] ?? "No";
            form.DesigningStatus.text = decodedData["DesigningStatus"] ?? "Pending";
            form.DesignedBy.text = decodedData["DesignedBy"] ?? "";
            form.DesignerCreatedBy.text = decodedData["DesignerCreatedBy"] ?? "";
          });
        }
      } catch (e) {
        debugPrint("❌ Error fetching from Firestore: $e");
      }
    }
  }

  Future<String> _getCurrentUserName() async {
    try {
      final email = SessionManager.getEmail();
      if (email == null || email.isEmpty) return "Current User";

      final querySnapshot = await FirebaseFirestore.instance
          .collection("Staff")
          .where("Email", isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return "Current User";
      return querySnapshot.docs.first.data()["Name"] ?? "Current User";
    } catch (e) {
      return "Current User";
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);

    final bool isDesigningDone = form.DesigningStatus.text.trim().toLowerCase() == "done";
    final bool laserDone = form.LaserCuttingStatus.text.trim().toLowerCase() == "done";
    final bool rubberFixingDone = form.RubberFixingDone.text.trim().toLowerCase() == "yes";
    final bool whiteProfileRubber = form.WhiteProfileRubber.text.trim().toLowerCase() == "yes";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text("Designer 6"),
        backgroundColor: Colors.yellow,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            if (form.canView("StrippingType")) ...[
              AddableSearchDropdown(
                label: "Stripping",
                items: form.strippingTypes,
                initialValue: form.StrippingType.text.isEmpty ? "No" : form.StrippingType.text,
                onAdd: (newJob) => form.strippingTypes.add(newJob),
                onChanged: (v) => setState(() => form.StrippingType.text = (v ?? "No").trim()),
              ),
              const SizedBox(height: 30),
            ],

            if (form.canView("LaserCuttingStatus")) ...[
              FlexibleToggle(
                label: "Laser Cutting Status",
                inactiveText: "Pending", activeText: "Done",
                initialValue: laserDone,
                onChanged: (v) => setState(() => form.LaserCuttingStatus.text = v ? "Done" : "Pending"),
              ),
              const SizedBox(height: 30),
            ],

            if (form.canView("RubberFixingDone")) ...[
              FlexibleToggle(
                label: "Rubber Fixing Done",
                inactiveText: "No", activeText: "Yes",
                initialValue: rubberFixingDone,
                onChanged: (val) => setState(() => form.RubberFixingDone.text = val ? "Yes" : "No"),
              ),
              const SizedBox(height: 30),
            ],

            if (form.canView("WhiteProfileRubber")) ...[
              FlexibleToggle(
                label: "White Profile Rubber",
                inactiveText: "No", activeText: "Yes",
                initialValue: whiteProfileRubber,
                onChanged: (val) => setState(() => form.WhiteProfileRubber.text = val ? "Yes" : "No"),
              ),
              const SizedBox(height: 30),
            ],

            /// ✅ Designing Status
            if (form.canView("DesigningStatus")) ...[
              FlexibleToggle(
                label: "Designing",
                inactiveText: "Pending", activeText: "Done",
                initialValue: isDesigningDone,
                onChanged: (val) async {
                  setState(() => form.DesigningStatus.text = val ? "Done" : "Pending");
                  if (val) {
                    final userName = await _getCurrentUserName();
                    if (mounted) {
                      setState(() {
                        form.DesignedBy.text = userName;
                        form.DesignedByTimestamp.text = DateTime.now().toString();
                      });
                    }
                  } else {
                    form.DesignedBy.clear();
                    form.DesignedByTimestamp.clear();
                  }
                },
              ),
              const SizedBox(height: 30),
            ],

            /// 🟢 REPLACED BULKY TEXTFIELDS WITH CUSTOM COMPONENT 🟢
            if (form.canView("DesigningStatus") && isDesigningDone) ...[
              TextInput(
                label: "Designed By",
                controller: form.DesignedBy,
                readOnly: true,
                hint: "",
              ),
              const SizedBox(height: 16),
              TextInput(
                label: "Designed At",
                controller: form.DesignedByTimestamp,
                readOnly: true,
                hint: "",
              ),
              const SizedBox(height: 30),
            ],

            // 🟢 DISPATCHER UI 🟢
            if (isDesigningDone) ...[
              const Divider(thickness: 2),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  "Route Job To:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),

              if (form.canView("ReqAutoBending")) ...[
                FlexibleToggle(
                  label: "Auto Bending",
                  inactiveText: "NO", activeText: "YES",
                  initialValue: form.ReqAutoBending.text.toUpperCase() == "YES",
                  onChanged: (val) => setState(() => form.ReqAutoBending.text = val ? "YES" : "NO"),
                ),
                const SizedBox(height: 20),
              ],
              if (form.canView("ReqManualBending")) ...[
                FlexibleToggle(
                  label: "Manual Bending",
                  inactiveText: "NO", activeText: "YES",
                  initialValue: form.ReqManualBending.text.toUpperCase() == "YES",
                  onChanged: (val) => setState(() => form.ReqManualBending.text = val ? "YES" : "NO"),
                ),
                const SizedBox(height: 20),
              ],
              if (form.canView("ReqLaserCutting")) ...[
                FlexibleToggle(
                  label: "Laser Cutting",
                  inactiveText: "NO", activeText: "YES",
                  initialValue: form.ReqLaserCutting.text.toUpperCase() == "YES",
                  onChanged: (val) => setState(() => form.ReqLaserCutting.text = val ? "YES" : "NO"),
                ),
                const SizedBox(height: 20),
              ],
              if (form.canView("ReqRubber")) ...[
                FlexibleToggle(
                  label: "Rubber",
                  inactiveText: "NO", activeText: "YES",
                  initialValue: form.ReqRubber.text.toUpperCase() == "YES",
                  onChanged: (val) => setState(() => form.ReqRubber.text = val ? "YES" : "NO"),
                ),
                const SizedBox(height: 20),
              ],
              if (form.canView("ReqEmboss")) ...[
                FlexibleToggle(
                  label: "Emboss",
                  inactiveText: "NO", activeText: "YES",
                  initialValue: form.ReqEmboss.text.toUpperCase() == "YES",
                  onChanged: (val) => setState(() => form.ReqEmboss.text = val ? "YES" : "NO"),
                ),
                const SizedBox(height: 20),
              ],
              const SizedBox(height: 40),
            ],

            /// ✅ Submit Button
            if (form.canView("submitButton")) ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                    setState(() => isSubmitting = true);
                    try {
                      await form.submitDesignerForm();
                      if (mounted) context.go('/dashboard');
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                      );
                    } finally {
                      if (mounted) setState(() => isSubmitting = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF8D94B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text("Submit", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}