import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lightatech/FormComponents/TextInput.dart';
import 'package:lightatech/FormComponents/SearchableDropdownWithInitial.dart';
import 'package:lightatech/FormComponents/FlexibleToggle.dart';
import 'package:go_router/go_router.dart';

import '../new_form_scope.dart';

class RubberPage extends StatefulWidget {
  const RubberPage({super.key});

  @override
  State<RubberPage> createState() => _RubberPageState();
}

class _RubberPageState extends State<RubberPage> {
  bool loading = true;
  bool _loaded = false;
  bool rubberDone = false;

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
    final rubber =
    Map<String, dynamic>.from(data["rubber"]?["data"] ?? {});

    // 👀 VIEW DATA (from Designer)
    form.PartyName.text = designer["PartyName"] ?? "";
    form.ParticularJobName.text = designer["ParticularJobName"] ?? "";
    form.LpmAutoIncrement.text = lpm;

    // ✏️ RUBBER DATA
    form.RubberStatus.text = rubber["RubberStatus"] ?? "Pending";
    form.RubberCreatedBy.text = rubber["RubberCreatedBy"] ?? "";

    rubberDone =
        form.RubberStatus.text.toLowerCase() == "done";

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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Rubber"),
        backgroundColor: Colors.yellow,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            // ===== VIEW FIELDS =====

            // Party Name
            if (form.canView("PartyName"))
              TextInput(
                label: "Party Name",
                controller: form.PartyName,
                readOnly: true,
                hint: "",
              ),

            // Particular Job Name
            if (form.canView("ParticularJobName")) ...[
              const SizedBox(height: 16),
              TextInput(
                label: "Particular Job Name",
                controller: form.ParticularJobName,
                readOnly: true,
                hint: "",
              ),
            ],

            // LPM
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
              ignoring: false,
              child: Opacity(
                opacity: form.canEdit("RubberStatus") ? 1 : 0.6,
                child: FlexibleToggle(
                  label: "Rubber Status",
                  inactiveText: "Pending",
                  activeText: "Done",
                  initialValue: rubberDone,
                  onChanged: (v) {
                    setState(() {
                      rubberDone = v;
                      form.RubberStatus.text =
                      v ? "Done" : "Pending";
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            IgnorePointer(
              ignoring: false,
              child: Opacity(
                opacity: form.canEdit("RubberCreatedBy") ? 1 : 0.6,
                child: SearchableDropdownWithInitial(
                  label: "Rubber Created By",
                  items: form.parties,
                  initialValue: form.RubberCreatedBy.text.isEmpty
                      ? "Select"
                      : form.RubberCreatedBy.text,
                  onChanged: (v) {
                    form.RubberCreatedBy.text =
                        (v ?? "").trim();
                  },
                ),
              ),
            ),

            const SizedBox(height: 40),

            // ===== SAVE =====

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    final isDone =
                        form.RubberStatus.text.trim().toLowerCase() == "done";

                    await form.submitDepartmentForm("Rubber");

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