import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lightatech/FormComponents/TextInput.dart';
import 'package:lightatech/FormComponents/SearchableDropdownWithInitial.dart';
import 'package:lightatech/FormComponents/FlexibleToggle.dart';
import 'package:lightatech/core/session/session_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../new_form_scope.dart';
import 'package:go_router/go_router.dart';

class ManualBendingPage extends StatefulWidget {
  const ManualBendingPage({super.key});

  @override
  State<ManualBendingPage> createState() => _ManualBendingPageState();
}

class _ManualBendingPageState extends State<ManualBendingPage> {
  bool loading = true;
  bool _loaded = false;
  bool manualDone = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
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
    final designer = Map<String, dynamic>.from(data["designer"]?["data"] ?? {});
    final manual = Map<String, dynamic>.from(data["manualBending"]?["data"] ?? {});

    // 👀 DESIGNER VIEW DATA
    form.PartyName.text = designer["PartyName"] ?? "";
    form.ParticularJobName.text = designer["ParticularJobName"] ?? "";
    form.LpmAutoIncrement.text = lpm;

    // ✏ MANUAL DATA
    form.ManualBendingCreatedBy.text =
        manual["ManualBendingCreatedBy"] ?? "";
    form.ManualBendingCreatedByName.text =
        manual["ManualBendingCreatedByName"] ?? "";
    form.ManualBendingCreatedByTimestamp.text =
        manual["ManualBendingCreatedByTimestamp"] ?? "";

    form.ManualBendingStatus.text =
        manual["ManualBendingStatus"] ?? "Pending";

    manualDone =
        form.ManualBendingStatus.text.toLowerCase() == "done";

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
      appBar: AppBar(
        title: const Text("Manual Bending"),
        backgroundColor: Colors.yellow,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ===== VIEW FIELDS =====

            if (form.canView("PartyName"))
              TextInput(
                label: "Party Name",
                controller: form.PartyName,
                readOnly: true,
                hint: "",
              ),

            if (form.canView("ParticularJobName")) ...[
              const SizedBox(height: 16),
              TextInput(
                label: "Particular Job Name",
                controller: form.ParticularJobName,
                readOnly: true,
                hint: "",
              ),
            ],

            if (form.canView("LpmAutoIncrement")) ...[
              const SizedBox(height: 16),
              TextInput(
                label: "LPM Number",
                controller: form.LpmAutoIncrement,
                readOnly: true,
                hint: "",
              ),
            ],

            const SizedBox(height: 30),

            // ===== EDIT FIELDS =====

            /// ✅ Manual Bending Status Toggle
            IgnorePointer(
              ignoring: false,
              child: Opacity(
                opacity: form.canEdit("ManualBendingStatus") ? 1 : 0.6,
                child: FlexibleToggle(
                  label: "Manual Bending Status",
                  inactiveText: "Pending",
                  activeText: "Done",
                  initialValue: manualDone,
                  onChanged: (val) async {
                    setState(() {
                      manualDone = val;
                      form.ManualBendingStatus.text =
                      val ? "Done" : "Pending";
                    });

                    if (val) {
                      // ✅ When toggle is ON: auto-populate with current user's name and timestamp
                      final userName = await _getCurrentUserName();
                      if (mounted) {
                        setState(() {
                          form.ManualBendingCreatedByName.text = userName;
                          form.ManualBendingCreatedByTimestamp.text =
                              DateTime.now().toString();
                        });
                      }
                    } else {
                      // ✅ When toggle is OFF: clear both fields
                      form.ManualBendingCreatedByName.clear();
                      form.ManualBendingCreatedByTimestamp.clear();
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 30),

            /// ✅ READ-ONLY "Done By" Field (Shows when ManualBending is Done)
            if (manualDone) ...[
              // Read-only Name field
              TextField(
                controller: form.ManualBendingCreatedByName,
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
                controller: form.ManualBendingCreatedByTimestamp,
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

            const SizedBox(height: 40),

            // ===== SAVE =====

            if (true)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final isDone =
                          form.ManualBendingStatus.text.trim().toLowerCase() ==
                              "done";

                      final updateData = {
                        "manualBending": {
                          "submitted": true,
                          "data": {
                            "ManualBendingStatus":
                            form.ManualBendingStatus.text,
                            "ManualBendingCreatedBy":
                            form.ManualBendingCreatedBy.text,
                            "ManualBendingCreatedByName":
                            form.ManualBendingCreatedByName.text,
                            "ManualBendingCreatedByTimestamp":
                            form.ManualBendingCreatedByTimestamp.text,
                          },
                        },

                        // ✅ Only move forward if Done
                        "currentDepartment":
                        isDone ? "LaserCutting" : "ManualBending",

                        "updatedAt": FieldValue.serverTimestamp(),
                      };

                      // ✅ THIS IS THE MOST IMPORTANT LINE
                      if (isDone) {
                        updateData["visibleTo"] =
                            FieldValue.arrayUnion(["LaserCutting"]);
                      }

                      await FirebaseFirestore.instance
                          .collection("jobs")
                          .doc(form.LpmAutoIncrement.text)
                          .set(updateData, SetOptions(merge: true));

                      await form.submitDepartmentForm("ManualBending");
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