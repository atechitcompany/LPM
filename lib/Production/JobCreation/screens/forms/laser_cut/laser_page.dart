import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lightatech/FormComponents/TextInput.dart';
import 'package:lightatech/FormComponents/FlexibleToggle.dart';
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

  // 🚀 SMART ROUTING VARIABLES
  bool reqRubber = false;
  bool reqEmboss = false;

  // Controllers for all read-only fields
  final TextEditingController _remarkCtrl = TextEditingController();
  final TextEditingController _bladeCtrl = TextEditingController();
  final TextEditingController _designerCreatedByCtrl = TextEditingController();
  final TextEditingController _laserStatusViewCtrl = TextEditingController();
  final TextEditingController _laserCreatedByViewCtrl = TextEditingController();

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
      if (mounted) setState(() => loading = false);
      return;
    }

    try {
      final snap = await FirebaseFirestore.instance
          .collection("jobs")
          .doc(lpm)
          .get();

      if (!snap.exists) {
        if (mounted) setState(() => loading = false);
        return;
      }

      final data = snap.data()!;
      final designer = Map<String, dynamic>.from(data["designer"]?["data"] ?? {});
      final laser = Map<String, dynamic>.from(data["laserCutting"]?["data"] ?? {});

      // 🚀 SMART ROUTING CHECK
      reqRubber = (designer["ReqRubber"] ?? "").toString().trim().toUpperCase() == "YES";
      reqEmboss = (designer["ReqEmboss"] ?? "").toString().trim().toUpperCase() == "YES";

      // Status Logic
      final status = laser["LaserCuttingStatus"] ?? (laser["LaserPunchNew"] == "Yes" ? "Done" : "Pending");
      form.LaserCuttingStatus.text = status;
      _laserStatusViewCtrl.text = status;
      laserDone = status.toLowerCase() == "done";

      // EXACT DATA FILLING
      form.LpmAutoIncrement.text = lpm;

      String pJob = (designer["ParticularJobName"] ?? designer["particularJobName"] ?? "").toString().trim();
      form.ParticularJobName.text = pJob.isEmpty ? "Not Filled" : pJob;

      String ply = (designer["PlyType"] ?? "").toString().trim();
      form.PlyType.text = ply.isEmpty ? "Not Filled" : ply;

      String blade = (designer["Blade"] ?? "").toString().trim();
      _bladeCtrl.text = blade.isEmpty ? "Not Filled" : blade;

      // Remark
      String remarkText = (designer["Remark"] ?? "").toString().trim();
      _remarkCtrl.text = remarkText.isEmpty ? "No Remark" : remarkText;

      // Designer Name
      String designerCreatedBy = (designer["DesignerCreatedBy"] ?? "").toString().trim();
      _designerCreatedByCtrl.text = designerCreatedBy.isEmpty ? "Not Filled" : designerCreatedBy;

      // Laser Created By Logic
      String laserCreatedBy = (laser["LaserCuttingCreatedByName"] ?? "").toString().trim();
      _laserCreatedByViewCtrl.text = laserCreatedBy.isEmpty ? "Not Done Yet" : laserCreatedBy;

      form.LaserCuttingCreatedByName.text = laserCreatedBy;
      form.LaserCuttingCreatedByTimestamp.text = (laser["LaserCuttingCreatedByTimestamp"] ?? "").toString().trim();

    } catch (e) {
      debugPrint("❌ Error loading Laser Data: $e");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  // IMPROVED USER NAME FETCHING
  Future<String> _getCurrentUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userName = prefs.getString('userName');

      if (userName != null && userName.trim().isNotEmpty && userName.trim().toLowerCase() != 'user') {
        return userName;
      }

      String? email = SessionManager.getEmail() ?? prefs.getString('userEmail');

      if (email != null && email.trim().isNotEmpty) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection("Staff")
            .where("Email", isEqualTo: email.trim())
            .limit(1)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          userName = querySnapshot.docs.first.data()["Name"];
          if (userName != null && userName.trim().isNotEmpty) {
            await prefs.setString('userName', userName);
            return userName;
          }
        }
      }
      return "Current User";
    } catch (e) {
      debugPrint("❌ Error fetching username: $e");
      return "Current User";
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);
    final bool isEditMode = form.mode == "edit";

    if (loading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Colors.yellow)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Lasercut"),
        backgroundColor: Colors.yellow,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // =========================================================
            // 👀 DETAIL VIEW (Sirf jab Form View Mode mein ho)
            // =========================================================
            if (!isEditMode) ...[
              TextInput(label: "Particular Job Name", controller: form.ParticularJobName, readOnly: true, hint: ""),
              const SizedBox(height: 20),

              TextInput(label: "LPM Number", controller: form.LpmAutoIncrement, readOnly: true, hint: ""),
              const SizedBox(height: 20),

              TextInput(label: "Ply", controller: form.PlyType, readOnly: true, hint: ""),
              const SizedBox(height: 20),

              TextInput(label: "Blade", controller: _bladeCtrl, readOnly: true, hint: ""),
              const SizedBox(height: 20),

              TextInput(label: "Laser Cutting Status", controller: _laserStatusViewCtrl, readOnly: true, hint: ""),
              const SizedBox(height: 20),

              TextInput(label: "Remark", controller: _remarkCtrl, readOnly: true, hint: ""),
              const SizedBox(height: 20),

              TextInput(label: "Laser Cutting Created By", controller: _laserCreatedByViewCtrl, readOnly: true, hint: ""),
              const SizedBox(height: 20),

              TextInput(label: "Designer Created By", controller: _designerCreatedByCtrl, readOnly: true, hint: ""),
            ]
            // =========================================================
            // ✏️ EDIT VIEW (Jab Laser Worker ko status Update karna ho)
            // =========================================================
            else ...[
              TextInput(label: "Particular Job Name", controller: form.ParticularJobName, readOnly: true, hint: ""),
              const SizedBox(height: 20),

              TextInput(label: "LPM Number", controller: form.LpmAutoIncrement, readOnly: true, hint: ""),
              const SizedBox(height: 20),

              TextInput(label: "Ply", controller: form.PlyType, readOnly: true, hint: ""),
              const SizedBox(height: 20),

              TextInput(label: "Remark", controller: _remarkCtrl, readOnly: true, hint: ""),
              const SizedBox(height: 20),

              TextInput(label: "Designer Created By", controller: _designerCreatedByCtrl, readOnly: true, hint: ""),
              const SizedBox(height: 30),

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
                    setState(() {
                      form.LaserCuttingCreatedByName.text = "Fetching Name...";
                      form.LaserCuttingCreatedByTimestamp.text = "Updating Time...";
                    });

                    final userName = await _getCurrentUserName();
                    final formattedTime = "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} at ${TimeOfDay.now().format(context)}";

                    if (mounted) {
                      setState(() {
                        form.LaserCuttingCreatedByName.text = userName;
                        form.LaserCuttingCreatedByTimestamp.text = formattedTime;
                      });
                    }
                  } else {
                    setState(() {
                      form.LaserCuttingCreatedByName.clear();
                      form.LaserCuttingCreatedByTimestamp.clear();
                    });
                  }
                },
              ),
              const SizedBox(height: 30),

              if (laserDone) ...[
                TextInput(
                    label: "Laser Cutting Created By",
                    controller: form.LaserCuttingCreatedByName,
                    readOnly: true,
                    hint: "Name will appear here"
                ),
                const SizedBox(height: 20),

                TextInput(
                    label: "Done At",
                    controller: form.LaserCuttingCreatedByTimestamp,
                    readOnly: true,
                    hint: "Time will appear here"
                ),
                const SizedBox(height: 30),
              ],

              const SizedBox(height: 40),

              // 💾 SUBMIT BUTTON 🚀
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      final isDone = form.LaserCuttingStatus.text.trim().toLowerCase() == "done";

                      // 🚀 SMART ROUTING LOGIC
                      String nextDepartment = "LaserCutting";
                      List<String> newVisibleTo = ["LaserCutting"];

                      if (isDone) {
                        if (reqRubber) {
                          nextDepartment = "Rubber";
                          newVisibleTo.add("Rubber");
                        } else if (reqEmboss) {
                          nextDepartment = "Emboss";
                          newVisibleTo.add("Emboss");
                        } else {
                          nextDepartment = "Delivery";
                          newVisibleTo.add("Delivery");
                        }
                      }

                      final updateData = {
                        "laserCutting": {
                          "submitted": true,
                          "data": {
                            "LaserCuttingStatus": form.LaserCuttingStatus.text,
                            "LaserCuttingCreatedByName": form.LaserCuttingCreatedByName.text == "Fetching Name..." ? "" : form.LaserCuttingCreatedByName.text,
                            "LaserCuttingCreatedByTimestamp": form.LaserCuttingCreatedByTimestamp.text == "Updating Time..." ? "" : form.LaserCuttingCreatedByTimestamp.text,
                          },
                        },
                        "currentDepartment": nextDepartment,
                        "updatedAt": FieldValue.serverTimestamp(),
                      };

                      if (isDone) {
                        updateData["visibleTo"] = FieldValue.arrayUnion(newVisibleTo);
                      }

                      await FirebaseFirestore.instance
                          .collection("jobs")
                          .doc(form.LpmAutoIncrement.text)
                          .set(updateData, SetOptions(merge: true));

                      // 🚀 RESTORED: Form submission status (Prevents UI ghosting bugs)
                      await form.submitDepartmentForm("LaserCutting");

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                isDone ? "Job Moved to $nextDepartment!" : "Progress Saved!",
                                style: const TextStyle(color: Colors.white)
                            ),
                            backgroundColor: Colors.green
                        ),
                      );

                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/dashboard');
                      }

                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF8D94B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text("Save & Continue", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}