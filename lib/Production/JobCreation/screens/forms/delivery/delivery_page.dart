import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lightatech/FormComponents/TextInput.dart';
import 'package:lightatech/FormComponents/FlexibleToggle.dart';
import 'package:lightatech/FormComponents/FileUploadBox.dart'; // 🟢 ADD THIS IMPORT

import '../new_form_scope.dart';

class DeliveryPage extends StatefulWidget {
  const DeliveryPage({super.key});

  @override
  State<DeliveryPage> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {
  bool loading = true;
  bool _loaded = false;

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

    try {
      final snap = await FirebaseFirestore.instance
          .collection("jobs")
          .doc(lpm)
          .get();

      if (!snap.exists) {
        setState(() => loading = false);
        return;
      }

      final data = snap.data()!;

      // ── Pulling data from ALL previous departments ──
      final designer = Map<String, dynamic>.from(data["designer"]?["data"] ?? {});
      final autoBending = Map<String, dynamic>.from(data["autoBending"]?["data"] ?? {});
      final laserCutting = Map<String, dynamic>.from(data["laserCutting"]?["data"] ?? {});
      final account = Map<String, dynamic>.from(data["account"]?["data"] ?? {});
      final delivery = Map<String, dynamic>.from(data["delivery"]?["data"] ?? {});

      // ===== VIEW ONLY (Populating from history) =====
      form.PartyName.text = designer["PartyName"] ?? "";
      form.ParticularJobName.text = designer["ParticularJobName"] ?? "";
      form.LpmAutoIncrement.text = lpm;
      form.DeliveryAt.text = designer["DeliveryAt"] ?? account["DeliveryAt"] ?? "";
      form.Remark.text = designer["Remark"] ?? account["Remark"] ?? "";

      form.AutoBendingCreatedBy.text = autoBending["AutoBendingCreatedBy"] ?? "";
      form.LaserCuttingCreatedBy.text = laserCutting["LaserCuttingCreatedBy"] ?? "";
      form.AccountsCreatedBy.text = account["AccountsCreatedBy"] ?? "";

      // ===== EDITABLE DELIVERY DATA =====
      form.DeliveryStatus.text = delivery["DeliveryStatus"] ?? "Pending";
      form.AddressOutput.text = delivery["DeliveryAddress"] ?? "";
      form.DrawingAttachment.text = delivery["DrawingAttachment"] ?? ""; // 🟢 LOAD THE ATTACHMENT URL
      form.JobDone.text = delivery["JobDone"] ?? "NO";

    } catch (e) {
      debugPrint("❌ Error loading delivery data: $e");
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);
    final lpmParam = form.LpmAutoIncrement.text;
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Delivery"),
        backgroundColor: Colors.yellow,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // ================= VIEW FIELDS =================
            if (form.canView("PartyName"))
              TextInput(
                label: "Party Name",
                controller: form.PartyName,
                readOnly: true,
                hint: "",
              ),
            const SizedBox(height: 16),

            if (form.canView("ParticularJobName"))
              TextInput(
                label: "Particular Job Name",
                controller: form.ParticularJobName,
                readOnly: true,
                hint: "",
              ),
            const SizedBox(height: 16),

            if (form.canView("LpmAutoIncrement"))
              TextInput(
                label: "LPM",
                controller: form.LpmAutoIncrement,
                readOnly: true,
                hint: "",
              ),
            const SizedBox(height: 16),

            if (form.canView("Remark"))
              TextInput(
                label: "Remark",
                controller: form.Remark,
                readOnly: true,
                hint: "",
              ),
            const SizedBox(height: 16),

            if (form.canView("DeliveryAt"))
              TextInput(
                label: "Delivery at",
                controller: form.DeliveryAt,
                readOnly: true,
                hint: "",
              ),
            const SizedBox(height: 16),

            if (form.canView("AutoBendingCreatedBy"))
              TextInput(
                label: "Auto Bending Created By",
                controller: form.AutoBendingCreatedBy,
                readOnly: true,
                hint: "",
              ),
            const SizedBox(height: 16),

            if (form.canView("LaserCuttingCreatedBy"))
              TextInput(
                label: "Laser Cutting Created By",
                controller: form.LaserCuttingCreatedBy,
                readOnly: true,
                hint: "",
              ),
            const SizedBox(height: 16),

            if (form.canView("AccountsCreatedBy"))
              TextInput(
                label: "Accounts Created By",
                controller: form.AccountsCreatedBy,
                readOnly: true,
                hint: "",
              ),
            const SizedBox(height: 30),


            // ================= EDIT FIELDS =================

            if (form.canView("DeliveryStatus")) ...[
              IgnorePointer(
                ignoring: !form.canEdit("DeliveryStatus"),
                child: Opacity(
                  opacity: form.canEdit("DeliveryStatus") ? 1 : 0.6,
                  child: FlexibleToggle(
                    label: "Delivery",
                    inactiveText: "Pending",
                    activeText: "Done",
                    initialValue: form.DeliveryStatus.text.toLowerCase() == "done",
                    onChanged: (val) {
                      setState(() {
                        form.DeliveryStatus.text = val ? "Done" : "Pending";
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (form.canView("AddressOutput")) ...[
              IgnorePointer(
                ignoring: !form.canEdit("AddressOutput"),
                child: Opacity(
                  opacity: form.canEdit("AddressOutput") ? 1 : 0.6,
                  child: TextInput(
                    label: "Delivery Address",
                    controller: form.AddressOutput,
                    hint: "Enter full delivery address",
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // ================= DRAWING ATTACHMENT =================
            // ================= DRAWING ATTACHMENT =================
            if (form.canView("DrawingAttachment")) ...[
              IgnorePointer(
                ignoring: !form.canEdit("DrawingAttachment"),
                child: Opacity(
                  opacity: form.canEdit("DrawingAttachment") ? 1 : 0.6,
                  child: FileUploadBox(
                    jobId:     lpmParam,           // ✅ ADD
                    fieldName: 'DrawingAttachment', // ✅ ADD
                    onFileSelected: (uploadedData) {
                      setState(() {
                        form.DrawingAttachment.text = uploadedData.toString();
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (form.canView("JobDone")) ...[
              IgnorePointer(
                ignoring: !form.canEdit("JobDone"),
                child: Opacity(
                  opacity: form.canEdit("JobDone") ? 1 : 0.6,
                  child: FlexibleToggle(
                    label: "Job Done",
                    inactiveText: "NO",
                    activeText: "YES",
                    initialValue: form.JobDone.text.toUpperCase() == "YES",
                    onChanged: (val) {
                      setState(() {
                        form.JobDone.text = val ? "YES" : "NO";
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],

            // ================= SAVE BUTTON =================
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    // Check if the final toggle is set to YES
                    final isCompleted = form.JobDone.text.trim().toUpperCase() == "YES";

                    final updateData = {
                      "delivery": {
                        "submitted": true,
                        "data": {
                          "DeliveryStatus": form.DeliveryStatus.text,
                          "DeliveryAddress": form.AddressOutput.text,
                          "DrawingAttachment": form.DrawingAttachment.text, // 🟢 SAVE THE ATTACHMENT URL
                          "JobDone": form.JobDone.text,
                        },
                      },
                      // 🟢 The magic line: Closes the pipeline!
                      "currentDepartment": isCompleted ? "Completed" : "Delivery",
                      "updatedAt": FieldValue.serverTimestamp(),
                    };

                    await FirebaseFirestore.instance
                        .collection("jobs")
                        .doc(form.LpmAutoIncrement.text)
                        .set(updateData, SetOptions(merge: true));

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isCompleted ? "Job Fully Completed!" : "Delivery Form Saved")),
                    );

                    context.go('/dashboard');
                  } catch (e) {
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    )
                ),
                child: const Text("Save & Complete Job", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}