import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lightatech/FormComponents/TextInput.dart';
import 'package:lightatech/FormComponents/SearchableDropdownWithInitial.dart';
import 'package:lightatech/FormComponents/FlexibleToggle.dart';
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

    form.ManualBendingStatus.text =
        manual["ManualBendingStatus"] ?? "Pending";

    manualDone =
        form.ManualBendingStatus.text.toLowerCase() == "done";

    setState(() => loading = false);
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

            IgnorePointer(
              ignoring: !form.canEdit("ManualBendingStatus"),
              child: Opacity(
                opacity: form.canEdit("ManualBendingStatus") ? 1 : 0.6,
                child: FlexibleToggle(
                  label: "Manual Bending Status",
                  inactiveText: "Pending",
                  activeText: "Done",
                  initialValue: manualDone,
                  onChanged: (v) {
                    setState(() {
                      manualDone = v;
                      form.ManualBendingStatus.text =
                      v ? "Done" : "Pending";
                    });
                  },
                ),
              ),
            ),


            IgnorePointer(
              ignoring: !form.canEdit("ManualBendingCreatedBy"),
              child: Opacity(
                opacity: form.canEdit("ManualBendingCreatedBy") ? 1 : 0.6,
                child: SearchableDropdownWithInitial(
                  label: "Manual Bending Created By",
                  items: form.parties,
                  initialValue: form.ManualBendingCreatedBy.text.isEmpty
                      ? "Select"
                      : form.ManualBendingCreatedBy.text,
                  onChanged: (v) {
                    form.ManualBendingCreatedBy.text =
                        (v ?? "").trim();
                  },
                ),
              ),
            ),


            const SizedBox(height: 40),

            // ===== SAVE =====

            if (form.canEdit("ManualBendingCreatedBy"))
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    await FirebaseFirestore.instance
                        .collection("jobs")
                        .doc(form.LpmAutoIncrement.text)
                        .set({
                      "manualBending": {
                        "submitted": true,
                        "data": {
                          "ManualBendingStatus":
                          form.ManualBendingStatus.text,
                          "ManualBendingCreatedBy":
                          form.ManualBendingCreatedBy.text,
                        },
                      },
                    "currentDepartment": "LaserCutting",
                    "updatedAt": FieldValue.serverTimestamp(),
                  }, SetOptions(merge: true));

                  context.pop(); // ✅ CORRECT
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Form submitted successfully")),
                  );
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
