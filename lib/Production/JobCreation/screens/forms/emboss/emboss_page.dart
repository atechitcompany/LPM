import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lightatech/FormComponents/TextInput.dart';
import 'package:lightatech/FormComponents/SearchableDropdownWithInitial.dart';
import 'package:lightatech/FormComponents/AddableSearchDropdown.dart';
import 'package:lightatech/FormComponents/FlexibleToggle.dart';
import '../new_form_scope.dart';
import 'package:go_router/go_router.dart';

class EmbossPage extends StatefulWidget {
  const EmbossPage({super.key});

  @override
  State<EmbossPage> createState() => _EmbossPageState();
}

class _EmbossPageState extends State<EmbossPage> {
  bool loading = true;
  bool _loaded = false;
  bool embossDone = false;

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

    // ── Designer data (read-only) ──
    final designer = Map<String, dynamic>.from(
      data["designer"]?["data"] ?? {},
    );

    // ── Emboss data (editable) ──
    final emboss = Map<String, dynamic>.from(
      data["emboss"]?["data"] ?? {},
    );

    // Read-only fields from designer
    form.PartyName.text = designer["PartyName"] ?? "";
    form.ParticularJobName.text = designer["ParticularJobName"] ?? "";
    form.LpmAutoIncrement.text = lpm;
    form.DesigningStatus.text = designer["DesigningStatus"] ?? "";
    form.DesignerCreatedBy.text = designer["DesignerCreatedBy"] ?? "";

    // Editable emboss fields
    form.EmbossStatus.text = emboss["EmbossStatus"] ?? "Pending";
    form.MaleEmbossType.text = emboss["MaleEmbossType"] ?? "";
    form.FemaleEmbossType.text = emboss["FemaleEmbossType"] ?? "";
    form.EmbossCreatedBy.text = emboss["EmbossCreatedBy"] ?? "";

    embossDone = form.EmbossStatus.text.trim().toLowerCase() == "done";

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
        title: const Text("Emboss"),
        backgroundColor: Colors.yellow,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ───────────── READ-ONLY FIELDS ─────────────

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

            if (form.canView("DesigningStatus")) ...[
              const SizedBox(height: 16),
              TextInput(
                label: "Designing",
                controller: form.DesigningStatus,
                readOnly: true,
                hint: "",
              ),
            ],

            const SizedBox(height: 30),

            // ───────────── EDIT FIELDS ─────────────

            FlexibleToggle(
              label: "Emboss",
              inactiveText: "Pending",
              activeText: "Done",
              initialValue: embossDone,
              onChanged: (v) {
                setState(() {
                  embossDone = v;
                  form.EmbossStatus.text = v ? "Done" : "Pending";
                });
              },
            ),

            const SizedBox(height: 20),

            AddableSearchDropdown(
              label: "Male Emboss",
              items: form.embossTypes,
              initialValue: form.MaleEmbossType.text.isEmpty
                  ? null
                  : form.MaleEmbossType.text,
              onChanged: (v) {
                setState(() {
                  form.MaleEmbossType.text = (v ?? "").trim();
                });
              },
              onAdd: (newVal) {
                setState(() {
                  form.embossTypes.add(newVal);
                });
              },
            ),

            const SizedBox(height: 20),

            AddableSearchDropdown(
              label: "Female Emboss",
              items: form.embossTypes,
              initialValue: form.FemaleEmbossType.text.isEmpty
                  ? null
                  : form.FemaleEmbossType.text,
              onChanged: (v) {
                setState(() {
                  form.FemaleEmbossType.text = (v ?? "").trim();
                });
              },
              onAdd: (newVal) {
                setState(() {
                  form.embossTypes.add(newVal);
                });
              },
            ),

            const SizedBox(height: 20),

            if (form.canView("DesignerCreatedBy"))
              TextInput(
                label: "Designer Created By",
                controller: form.DesignerCreatedBy,
                readOnly: true,
                hint: "",
              ),

            const SizedBox(height: 20),

            SearchableDropdownWithInitial(
              label: "Emboss Created By",
              items: form.parties,
              initialValue: form.EmbossCreatedBy.text.isEmpty
                  ? "Select"
                  : form.EmbossCreatedBy.text,
              onChanged: (v) {
                form.EmbossCreatedBy.text = (v ?? "").trim();
              },
            ),

            const SizedBox(height: 40),

            // ───────────── SAVE ─────────────

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    final isDone =
                        form.EmbossStatus.text.trim().toLowerCase() == "done";

                    await form.submitDepartmentForm("Emboss");
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Form submitted successfully"),
                      ),
                    );

                    context.pop();
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF8D94B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  "Save & Continue",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}