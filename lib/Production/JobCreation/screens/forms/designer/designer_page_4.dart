import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../new_form_scope.dart';
import 'package:lightatech/FormComponents/AddableSearchDropdown.dart';
import 'package:lightatech/FormComponents/FlexibleToggle.dart';
import 'package:lightatech/FormComponents/TextInput.dart'; // 🟢 Added your TextInput component!
import 'package:lightatech/core/session/session_manager.dart';
import 'package:lightatech/FormComponents/FileUploadBox.dart';
import 'package:lightatech/FormComponents/SearchableDropdownWithInitial.dart';
import 'dart:convert';

class DesignerPage4 extends StatefulWidget {
  const DesignerPage4({super.key});

  @override
  State<DesignerPage4> createState() => _DesignerPage4State();
}

class _DesignerPage4State extends State<DesignerPage4> {
  bool isSubmitting = false;
  bool _initialized = false;
  //TO-D2
  List<String> _strippingItems = ["No"];
  bool _loadingStrippings = true;
  //EN-D2
  @override
  void initState() {
    super.initState();
    _fetchStrippings();
  }
  //TO-D2
  Future<void> _fetchStrippings() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection("Strippings")
          .get();

      final items = snap.docs
          .map((doc) => (doc.data()['Strippings'] ?? '').toString())
          .where((val) => val.isNotEmpty)
          .toList();

      setState(() {
        _strippingItems = ["No", ...items];
        _loadingStrippings = false;
      });
    } catch (e) {
      debugPrint("❌ Error fetching Strippings: $e");
      setState(() => _loadingStrippings = false);
    }
  }
  //EN-D2
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
        form.LaserCuttingStatus.text =
            decodedData["LaserCuttingStatus"] ?? "Pending";
        form.RubberFixingDone.text = decodedData["RubberFixingDone"] ?? "No";
        form.WhiteProfileRubber.text =
            decodedData["WhiteProfileRubber"] ?? "No";
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

  /// ✅ Gets current logged-in user's name
  Future<String> _getCurrentUserName() async {
    try {
      // Method 1: Try SharedPreferences 'userName' (set during login)
      final prefs = await SharedPreferences.getInstance();
      String? userName = prefs.getString('userName');

      if (userName != null && userName.isNotEmpty && userName != 'User') {
        debugPrint("✅ Got user name from SharedPreferences: $userName");
        return userName;
      }

      // Method 2: Try SessionManager email
      String? email = SessionManager.getEmail();
      if (email != null && email.isNotEmpty) {
        // Query Staff collection
        final querySnapshot = await FirebaseFirestore.instance
            .collection("Staff")
            .where("Email", isEqualTo: email)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          userName = querySnapshot.docs.first.data()["Name"];
          if (userName != null && userName.isNotEmpty) {
            debugPrint("✅ Got user name from Staff: $userName");
            return userName;
          }
        }
      }

      // Method 3: Try SharedPreferences 'userEmail'
      email = prefs.getString('userEmail');
      if (email != null && email.isNotEmpty) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection("Staff")
            .where("Email", isEqualTo: email)
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          userName = querySnapshot.docs.first.data()["Name"];
          if (userName != null && userName.isNotEmpty) {
            debugPrint("✅ Got user name from Staff (via userEmail): $userName");
            return userName;
          }
        }
      }

      debugPrint("⚠️ Could not find user name, returning 'Unknown'");
      return "Unknown";
    } catch (e) {
      debugPrint("❌ Error getting current user name: $e");
      return "Unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);
    final approvalStatus = form.SendApproval.text; // temp fallback
    final lpmParam = form.LpmAutoIncrement.text;
    final bool isDesigningDone = form.DesigningStatus.text.trim().toLowerCase() == "done";
    final bool laserDone = form.LaserCuttingStatus.text.trim().toLowerCase() == "done";
    final bool rubberFixingDone = form.RubberFixingDone.text.trim().toLowerCase() == "yes";
    final bool whiteProfileRubber = form.WhiteProfileRubber.text.trim().toLowerCase() == "yes";
    final mainJobId = lpmParam.contains('-')
        ? lpmParam.split('-').take(4).join('-')  // "LPM-00001-04-26"
        : lpmParam;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text("Designer 4"),
        backgroundColor: Colors.yellow,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            if (form.canView("RubberFixingDone")) ...[
              FlexibleToggle(
                label: "Rubber Fixing Done",
                inactiveText: "No", activeText: "Yes",
                initialValue: rubberFixingDone,
                onChanged: (val) => setState(() => form.RubberFixingDone.text = val ? "Yes" : "No"),
              ),
              const SizedBox(height: 20),
            ],

            if (form.canView("WhiteProfileRubber")) ...[
              FlexibleToggle(
                label: "White Profile Rubber",
                inactiveText: "No", activeText: "Yes",
                initialValue: whiteProfileRubber,
                onChanged: (val) => setState(() => form.WhiteProfileRubber.text = val ? "Yes" : "No"),
              ),
              const SizedBox(height: 20),
            ],

            /// ✅ Drawing Attachment
            if (form.canView("DrawingAttachment")) ...[
              const Text(
                "Drawing Attachment",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              FileUploadBox(
                jobId:     mainJobId,            // ✅ e.g. "LPM-00001-04-26-01"
                fieldName: 'DrawingAttachment',
                onFileSelected: (file) {
                  debugPrint("Drawing: ${file.name}");
                },
              ),
              const SizedBox(height: 20),
            ],

            /// ✅ Rubber Report (only when designing done)
            if (isDesigningDone && form.canView("RubberReport")) ...[
              const Text(
                "Rubber Report",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              FileUploadBox(
                jobId:     mainJobId,
                fieldName: 'RubberReport',
                onFileSelected: (file) {
                  debugPrint("Rubber: ${file.name}");
                },
              ),
              const SizedBox(height: 20),
            ],

            /// ✅ Punch Report
            if (form.canView("PunchReport")) ...[
              const Text(
                "Punch Report",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              FileUploadBox(
                jobId:     mainJobId,
                fieldName: 'PunchReport',
                onFileSelected: (file) {
                  debugPrint("Punch: ${file.name}");
                },
              ),
              const SizedBox(height: 20),
            ],


            /// ✅ Designing Status
            if (form.canView("DesigningStatus")) ...[
              FlexibleToggle(
                label: "Designing",
                inactiveText: "Pending", activeText: "Done",
                initialValue: isDesigningDone,
                onChanged: (val) async {
                  setState(() {
                    form.DesigningStatus.text = val ? "Done" : "Pending";
                  });

                  if (val) {
                    final userName = await _getCurrentUserName();
                    if (mounted) {
                      setState(() {
                        form.DesignedBy.text = userName;
                        form.DesignedByTimestamp.text = DateTime.now()
                            .toString();
                      });
                    }
                  } else {
                    form.DesignedBy.clear();
                    form.DesignedByTimestamp.clear();
                  }
                },
              ),
              const SizedBox(height: 20),
            ],

            /// 🟢 REPLACED BULKY TEXTFIELDS WITH CUSTOM COMPONENT 🟢
            if (form.canView("DesigningStatus") && isDesigningDone) ...[
              TextField(
                controller: form.DesignedBy,
                enabled: false, // ← NOT EDITABLE
                decoration: InputDecoration(
                  labelText: "Designed By",
                  labelStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: form.DesignedByTimestamp,
                enabled: false, // ← NOT EDITABLE
                decoration: InputDecoration(
                  labelText: "Designed At",
                  labelStyle: const TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                style: const TextStyle(color: Colors.black87, fontSize: 12),
              ),
              const SizedBox(height: 20),
            ],

            // 🟢 DISPATCHER UI 🟢


            /// ✅ Send Approval

            if (form.canView("SendApproval") && approvalStatus != "changes") ...[
              SearchableDropdownWithInitial(
                label: "Send Approval",
                items: const ["YES", "NO"],
                initialValue: form.SendApproval.text.isEmpty
                    ? null
                    : form.SendApproval.text,
                onChanged: (v) {
                  setState(() {
                    form.SendApproval.text = (v ?? "").trim();
                  });
                },
              ),
              const SizedBox(height: 20),
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
