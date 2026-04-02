import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lightatech/FormComponents/TextInput.dart';
import 'package:lightatech/FormComponents/SearchableDropdownWithInitial.dart';
import 'package:lightatech/FormComponents/FlexibleToggle.dart';
import 'package:lightatech/core/session/session_manager.dart';

import '../new_form_scope.dart';

class AutoBendingPage extends StatefulWidget {
  const AutoBendingPage({super.key});

  @override
  State<AutoBendingPage> createState() => _AutoBendingPageState();
}

class _AutoBendingPageState extends State<AutoBendingPage> {
  bool loading = true;
  bool _loaded = false;
  bool autobendingstatus = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_loaded) return;
    _loaded = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryLoad();
    });
  }

  Future<void> _tryLoad() async {
    // Get lpm directly from URL, don't wait for form
    final uri = GoRouterState.of(context).uri;
    final lpm = uri.queryParameters['lpm'];

    debugPrint("🔍 AutoBending - LPM from URL: $lpm");

    if (lpm == null || lpm.isEmpty) {
      debugPrint("❌ AutoBending - No LPM in URL!");
      setState(() => loading = false);
      return;
    }

    await _loadData(lpm);
  }

  Future<void> _loadData(String lpm) async {
    debugPrint("🔍 AutoBending - Loading data for LPM: $lpm");

    final form = NewFormScope.of(context);

    try {
      final snap = await FirebaseFirestore.instance
          .collection("jobs")
          .doc(lpm)
          .get();

      debugPrint(
        "🔍 AutoBending - Firestore query complete, exists: ${snap.exists}",
      );

      if (!snap.exists) {
        debugPrint("❌ AutoBending - Document does not exist!");
        setState(() => loading = false);
        return;
      }

      final data = snap.data()!;
      debugPrint("🔍 AutoBending - Document data keys: ${data.keys.toList()}");

      final designer = Map<String, dynamic>.from(
        data["designer"]?["data"] ?? {},
      );
      final autoBending = Map<String, dynamic>.from(
        data["autoBending"]?["data"] ?? {},
      );

      debugPrint("🔍 AutoBending - designer data: ${designer.keys.toList()}");
      debugPrint(
        "🔍 AutoBending - autoBending data: ${autoBending.keys.toList()}",
      );

      // 🔒 DESIGNER (VIEW ONLY)
      form.PartyName.text = designer["PartyName"] ?? "";
      form.DeliveryAt.text = designer["DeliveryAt"] ?? "";
      form.OrderBy.text = designer["Orderby"] ?? "";
      form.ParticularJobName.text = designer["ParticularJobName"] ?? "";
      form.Priority.text = designer["Priority"] ?? "";

      // 🔒 LPM
      form.LpmAutoIncrement.text = lpm;

      // ✏️ AUTOBENDING
      form.AutoBendingCreatedBy.text =
          autoBending["AutoBendingCreatedBy"] ?? "";
      form.AutoBendingCreatedByName.text =
          autoBending["AutoBendingCreatedByName"] ?? "";
      form.AutoBendingCreatedByTimestamp.text =
          autoBending["AutoBendingCreatedByTimestamp"] ?? "";

      form.AutoCreasing = autoBending["AutoCreasing"] == true;

      form.AutoCreasingStatus.text =
          autoBending["AutoCreasingStatus"] ?? "Pending";

      form.AutoBendingStatus.text =
          autoBending["AutoBendingStatus"] ?? "Pending";

      autobendingstatus = form.AutoBendingStatus.text.toLowerCase() == "done";

      debugPrint("🔍 AutoBending - autobendingstatus: $autobendingstatus");

      setState(() => loading = false);
    } catch (e) {
      debugPrint("❌ AutoBending - Error loading data: $e");
      setState(() => loading = false);
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

    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Autobending"),
        backgroundColor: Colors.yellow,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔒 DESIGNER DATA (VIEW ONLY)
            TextInput(
              label: "Party Name",
              hint: "",
              controller: form.PartyName,
              readOnly: true,
            ),
            const SizedBox(height: 20),

            TextInput(
              label: "Delivery At",
              hint: "",
              controller: form.DeliveryAt,
              readOnly: true,
            ),
            const SizedBox(height: 20),

            TextInput(
              label: "Order By",
              hint: "",
              controller: form.OrderBy,
              readOnly: true,
            ),
            const SizedBox(height: 20),

            TextInput(
              label: "Particular Job Name",
              hint: "",
              controller: form.ParticularJobName,
              readOnly: true,
            ),
            const SizedBox(height: 20),

            TextInput(
              label: "LPM Number",
              hint: "",
              controller: form.LpmAutoIncrement,
              readOnly: true,
            ),
            const SizedBox(height: 20),

            TextInput(
              label: "Priority",
              hint: "",
              controller: form.Priority,
              readOnly: true,
            ),

            const SizedBox(height: 30),

            /// ✅ AutoBending Status Toggle
            FlexibleToggle(
              label: "AutoBending *",
              inactiveText: "Pending",
              activeText: "Done",
              initialValue: autobendingstatus,
              onChanged: (val) async {
                setState(() {
                  autobendingstatus = val;
                  form.AutoBendingStatus.text = val ? "Done" : "Pending";
                });

                if (val) {
                  // ✅ When toggle is ON: auto-populate with current user's name and timestamp
                  final userName = await _getCurrentUserName();
                  if (mounted) {
                    setState(() {
                      form.AutoBendingCreatedByName.text = userName;
                      form.AutoBendingCreatedByTimestamp.text = DateTime.now()
                          .toString();
                    });
                  }
                } else {
                  // ✅ When toggle is OFF: clear both fields
                  form.AutoBendingCreatedByName.clear();
                  form.AutoBendingCreatedByTimestamp.clear();
                }
              },
            ),
            const SizedBox(height: 30),

            /// ✅ READ-ONLY "Created By" Field (Shows when AutoBending is Done)
            if (autobendingstatus) ...[
              // Read-only Name field
              TextField(
                controller: form.AutoBendingCreatedByName,
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
                controller: form.AutoBendingCreatedByTimestamp,
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

            FlexibleToggle(
              label: "Auto Creasing",
              inactiveText: "No",
              activeText: "Yes",
              initialValue: form.AutoCreasing,
              onChanged: (v) {
                setState(() {
                  form.AutoCreasing = v;
                });
              },
            ),

            if (form.AutoCreasing) ...[
              const SizedBox(height: 20),
              FlexibleToggle(
                label: "Auto Creasing Status",
                inactiveText: "Pending",
                activeText: "Done",
                initialValue:
                    form.AutoCreasingStatus.text.toLowerCase() == "done",
                onChanged: (v) {
                  form.AutoCreasingStatus.text = v ? "Done" : "Pending";
                },
              ),
            ],

            const SizedBox(height: 40),

            /// ✅ SAVE & CONTINUE
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    final isDone =
                        form.AutoBendingStatus.text.trim().toLowerCase() ==
                        "done";

                    final updateData = {
                      "autoBending": {
                        "submitted": true,
                        "data": {
                          "AutoBendingStatus": form.AutoBendingStatus.text,
                          "AutoBendingCreatedBy":
                              form.AutoBendingCreatedBy.text,
                          "AutoBendingCreatedByName":
                              form.AutoBendingCreatedByName.text,
                          "AutoBendingCreatedByTimestamp":
                              form.AutoBendingCreatedByTimestamp.text,
                          "AutoCreasing": form.AutoCreasing,
                          "AutoCreasingStatus": form.AutoCreasingStatus.text,
                        },
                      },
                      "currentDepartment": isDone
                          ? "ManualBending"
                          : "AutoBending",
                      "updatedAt": FieldValue.serverTimestamp(),
                    };

                    // ✅ Only add ManualBending if Done
                    if (isDone) {
                      updateData["visibleTo"] = FieldValue.arrayUnion([
                        "ManualBending",
                      ]);
                    }

                    await FirebaseFirestore.instance
                        .collection("jobs")
                        .doc(form.LpmAutoIncrement.text)
                        .set(updateData, SetOptions(merge: true));

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Form submitted successfully"),
                      ),
                    );

                    Navigator.pop(context);
                  } catch (e) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Error: $e")));
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
