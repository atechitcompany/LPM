import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lightatech/Production/JobCreation/screens/forms/new_form.dart';
import 'package:lightatech/FormComponents/SearchableDropdownWithInitial.dart';
import 'package:lightatech/FormComponents/TextInput.dart';
import 'package:lightatech/FormComponents/AddableSearchDropdown.dart';
import 'package:lightatech/FormComponents/GSTSelector.dart';
import 'package:lightatech/FormComponents/AutoIncrementField.dart';
import 'package:lightatech/FormComponents/PrioritySelector.dart';
import 'package:lightatech/FormComponents/FlexibleToggle.dart';
import 'package:lightatech/FormComponents/FileUploadBox.dart';
import 'package:lightatech/FormComponents/FlexibleSlider.dart';
import 'package:lightatech/FormComponents/NumberStepper.dart';
import 'package:lightatech/FormComponents/AutoCalcTextbox.dart';
import 'package:go_router/go_router.dart';
import 'package:lightatech/core/session/session_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../new_form_scope.dart';

class LaserPage extends StatefulWidget {
  const LaserPage({super.key});

  @override
  State<LaserPage> createState() => _LaserPageState();
}

class _LaserPageState extends State<LaserPage> {
  bool loading = true;
  bool _loaded = false;
  bool laserDone = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final form = NewFormScope.of(context);
    final lpm = form.LpmAutoIncrement.text;

    if (lpm.isEmpty) {
      setState(() => loading = false);
      return;
    }

    final snap = await FirebaseFirestore.instance
        .collection("jobs")
        .doc(lpm)
        .get();

    if (!snap.exists) {
      setState(() => loading = false);
      return;
    }

    final data = snap.data()!;

    final designer =
    Map<String, dynamic>.from(data["designer"]?["data"] ?? {});

    final laser =
    Map<String, dynamic>.from(data["laserCutting"]?["data"] ?? {});
    final status = laser["LaserCuttingStatus"] ??
        (laser["LaserPunchNew"] == "Yes" ? "Done" : "Pending");

    form.LaserCuttingStatus.text = status;

    laserDone = status.toLowerCase() == "done";

    // 👀 LOAD DESIGNER DATA (VIEW)
    form.ParticularJobName.text = designer["ParticularJobName"] ?? "";
    form.LpmAutoIncrement.text = lpm;
    form.PlyType.text = designer["PlyType"] ?? "";
    form.PlySelectedBy.text = designer["PlySelectedBy"] ?? "";

    // ✏️ LASER DATA
    form.LaserCuttingStatus.text =
        laser["LaserCuttingStatus"] ?? "Pending";
    form.LaserCuttingCreatedByName.text =
        laser["LaserCuttingCreatedByName"] ?? "";
    form.LaserCuttingCreatedByTimestamp.text =
        laser["LaserCuttingCreatedByTimestamp"] ?? "";

    laserDone = form.LaserCuttingStatus.text.toLowerCase() == "done";

    setState(() => loading = false);
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

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          title: const Text("Lasercut"), backgroundColor: Colors.yellow),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            //LPM View access
            TextInput(
              label: "LPM Number",
              controller: form.LpmAutoIncrement,
              readOnly: true,
              hint: "",
            ),
            const SizedBox(height: 20),
            //Particular Job name View access
            TextInput(
              label: "Particular Job Name",
              controller: form.ParticularJobName,
              readOnly: true,
              hint: "",
            ),
            const SizedBox(height: 20),

            /// ✅ Laser Cutting Status Toggle
            FlexibleToggle(
              label: "Laser Cutting Status",
              inactiveText: "Pending",
              activeText: "Done",
              initialValue: laserDone,
              onChanged: (val) async {
                setState(() {
                  laserDone = val;
                  form.LaserCuttingStatus.text = val ? "Done" : "Pending";
                });

                if (val) {
                  // ✅ When toggle is ON: auto-populate with current user's name and timestamp
                  final userName = await _getCurrentUserName();
                  if (mounted) {
                    setState(() {
                      form.LaserCuttingCreatedByName.text = userName;
                      form.LaserCuttingCreatedByTimestamp.text =
                          DateTime.now().toString();
                    });
                  }
                } else {
                  // ✅ When toggle is OFF: clear both fields
                  form.LaserCuttingCreatedByName.clear();
                  form.LaserCuttingCreatedByTimestamp.clear();
                }
              },
            ),

            const SizedBox(height: 30),

            /// ✅ READ-ONLY "Done By" Field (Shows when LaserCutting is Done)
            if (laserDone) ...[
              // Read-only Name field
              TextField(
                controller: form.LaserCuttingCreatedByName,
                enabled: false, // ← NOT EDITABLE
                decoration: InputDecoration(
                  labelText: "Done By",
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

              // Read-only Timestamp field
              TextField(
                controller: form.LaserCuttingCreatedByTimestamp,
                enabled: false, // ← NOT EDITABLE
                decoration: InputDecoration(
                  labelText: "Done At",
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
              const SizedBox(height: 30),
            ],

            //Ply View Access
            if (form.canView("PlyType")) ...[
              TextInput(
                label: "Ply Type",
                controller: form.PlyType,
                readOnly: true,
                hint: "",
              ),
            ],

            if (form.canView("PlySelectedBy")) ...[
              const SizedBox(height: 20),
              TextInput(
                label: "Ply Selected By",
                controller: form.PlySelectedBy,
                readOnly: true,
                hint: "",
              ),
            ],

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    final isDone = form.LaserCuttingStatus.text
                        .trim()
                        .toLowerCase() ==
                        "done";

                    final updateData = {
                      "laserCutting": {
                        "submitted": true,
                        "data": {
                          "LaserCuttingStatus": form.LaserCuttingStatus.text,
                          "LaserCuttingCreatedByName":
                          form.LaserCuttingCreatedByName.text,
                          "LaserCuttingCreatedByTimestamp":
                          form.LaserCuttingCreatedByTimestamp.text,
                          // ✅ REMOVE OLD FIELD
                          "LaserPunchNew": FieldValue.delete(),
                        },
                      },

                      // ✅ Workflow control
                      "currentDepartment": isDone ? "Rubber" : "LaserCutting",

                      "updatedAt": FieldValue.serverTimestamp(),
                    };

                    // ✅ Visibility control (MOST IMPORTANT)
                    if (isDone) {
                      updateData["visibleTo"] =
                          FieldValue.arrayUnion(["Rubber"]);
                    }

                    await FirebaseFirestore.instance
                        .collection("jobs")
                        .doc(form.LpmAutoIncrement.text)
                        .set(updateData, SetOptions(merge: true));

                    await form.submitDepartmentForm("LaserCutting");
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text("Form submitted successfully")),
                    );

                    context.pop();
                  } catch (e) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                },
                child: const Text("Save & Continue"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}