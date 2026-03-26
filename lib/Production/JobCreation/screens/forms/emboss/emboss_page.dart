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

import '../new_form_scope.dart';


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

    final emboss =
    Map<String, dynamic>.from(data["emboss"]?["data"] ?? {});

    // 👀 DESIGNER VIEW DATA
    form.PartyName.text = designer["PartyName"] ?? "";
    form.ParticularJobName.text = designer["ParticularJobName"] ?? "";
    form.LpmAutoIncrement.text = lpm;
    form.DesigningStatus.text = designer["DesigningStatus"] ?? "";

    form.HoleType.text = designer["HoleType"] ?? "";

    // ✏️ EMBOSS DATA
    form.EmbossStatus.text = emboss["EmbossStatus"] ?? "Pending";
    form.EmbossPcs.text = emboss["EmbossPcs"] ?? "";
    form.MaleEmbossType.text = emboss["MaleEmbossType"] ?? "";
    form.X.text = emboss["X"] ?? "";
    form.Y.text = emboss["Y"] ?? "";
    form.FemaleEmbossType.text = emboss["FemaleEmbossType"] ?? "";

    embossDone =
        form.EmbossStatus.text.toLowerCase() == "done";

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
        title: const Text("Emboss"),
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
                label: "LPM Number",
                controller: form.LpmAutoIncrement,
                readOnly: true,
                hint: "",
              ),

            const SizedBox(height: 16),

            if (form.canView("DesigningStatus"))
              TextInput(
                label: "Designing Status",
                controller: form.DesigningStatus,
                readOnly: true,
                hint: "",
              ),

            const SizedBox(height: 16),

            if (form.canView("HoleType"))
              TextInput(
                label: "Hole Type",
                controller: form.HoleType,
                readOnly: true,
                hint: "",
              ),

            const SizedBox(height: 30),

            // ===== EDIT FIELDS =====

            FlexibleToggle(
              label: "Emboss Status",
              inactiveText: "Pending",
              activeText: "Done",
              initialValue: embossDone,
              onChanged: (v) {
                setState(() {
                  embossDone = v;
                  form.EmbossStatus.text =
                  v ? "Done" : "Pending";
                });
              },
            ),

            const SizedBox(height: 20),

            TextInput(
              label: "Emboss PCS",
              controller: form.EmbossPcs,
              hint: "",
            ),

            const SizedBox(height: 20),

            TextInput(
              label: "Male Emboss Type",
              controller: form.MaleEmbossType,
              hint: "",
            ),

            const SizedBox(height: 20),

            TextInput(
              label: "X",
              controller: form.X,
              hint: "",
            ),

            const SizedBox(height: 20),

            TextInput(
              label: "Y",
              controller: form.Y,
              hint: "",
            ),

            const SizedBox(height: 20),

            TextInput(
              label: "Female Emboss Type",
              controller: form.FemaleEmbossType,
              hint: "",
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
                        form.EmbossStatus.text.toLowerCase() == "done";

                    final updateData = {
                      "emboss": {
                        "submitted": true,
                        "data": {
                          "EmbossStatus": form.EmbossStatus.text,
                          "EmbossPcs": form.EmbossPcs.text,
                          "MaleEmbossType": form.MaleEmbossType.text,
                          "X": form.X.text,
                          "Y": form.Y.text,
                          "FemaleEmbossType": form.FemaleEmbossType.text,
                        },
                      },

                      "currentDepartment":
                      isDone ? "Account" : "Emboss",

                      "updatedAt": FieldValue.serverTimestamp(),
                    };

                    if (isDone) {
                      updateData["visibleTo"] =
                          FieldValue.arrayUnion(["Account"]);
                    }

                    await FirebaseFirestore.instance
                        .collection("jobs")
                        .doc(form.LpmAutoIncrement.text)
                        .set(updateData, SetOptions(merge: true));

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
