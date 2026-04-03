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

    laserDone =
        form.LaserCuttingStatus.text.toLowerCase() == "done";

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
      appBar: AppBar(title: const Text("Lasercut"), backgroundColor: Colors.yellow),
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

            FlexibleToggle(
              label: "Laser Cutting Status",
              inactiveText: "Pending",
              activeText: "Done",
              initialValue: laserDone,
              onChanged: (val) {
                setState(() {
                  laserDone = val;
                  form.LaserCuttingStatus.text =
                  val ? "Done" : "Pending";
                });
              },
            ),

            //Ply View Access
            if (form.canView("PlyType")) ...[
              const SizedBox(height: 20),
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
                    final isDone =
                        form.LaserCuttingStatus.text.trim().toLowerCase() == "done";

                    await form.submitDepartmentForm("LaserCutting");
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Form submitted successfully")),
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
