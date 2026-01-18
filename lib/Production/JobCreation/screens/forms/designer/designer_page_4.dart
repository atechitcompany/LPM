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

import '../new_form_scope.dart';

class DesignerPage4 extends StatefulWidget {
  const DesignerPage4({super.key});

  @override
  State<DesignerPage4> createState() => _DesignerPage4State();
}

class _DesignerPage4State extends State<DesignerPage4> {
  String selectedByText(BuildContext context) {
    return "Company on ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} at ${TimeOfDay.now().format(context)}";
  }

  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);

    bool isPerforationSelected =
        form.Perforation.text.trim().toLowerCase() != "no";

    bool isZigZagBladeSelected =
        form.ZigZagBlade.text.trim().toLowerCase() != "no";

    bool isRubberSelected =
        form.RubberType.text.trim().toLowerCase() != "no";

    bool isHoleSelected =
        form.HoleType.text.trim().toLowerCase() != "no";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Designer 4"),
        backgroundColor: Colors.yellow,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Perforation
            AddableSearchDropdown(
              label: "Perforation",
              items: form.jobs,
              onAdd: (newJob) => form.jobs.add(newJob),
              initialValue: "No",
              onChanged: (v) {
                setState(() {
                  form.Perforation.text = v ?? "";
                });

                String selected = (v ?? "").trim();

                if (selected.toLowerCase() == "no") {
                  form.PerforationSelectedBy.clear();
                } else {
                  form.PerforationSelectedBy.text = selectedByText(context);
                }
              },
            ),

            // ✅ Perforation Done By
            if (isPerforationSelected) ...[
              const SizedBox(height: 20),
              const Text(
                "Perforation Done By",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: form.PerforationSelectedBy,
                enabled: false,
                decoration: InputDecoration(
                  hintText: "Will be filled automatically",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 26),

            // ✅ Zig Zag Blade
            AddableSearchDropdown(
              label: "Zig Zag Blade",
              items: form.jobs,
              initialValue: "No",
              onAdd: (newJob) => form.jobs.add(newJob),
              onChanged: (v) {
                setState(() {
                  form.ZigZagBlade.text = v ?? "";
                });

                String selected = (v ?? "").trim();

                if (selected.toLowerCase() == "no") {
                  form.ZigZagBladeSelectedBy.clear();
                } else {
                  form.ZigZagBladeSelectedBy.text = selectedByText(context);
                }
              },
            ),

            // ✅ Zig Zag Blade Selected By
            if (isZigZagBladeSelected) ...[
              const SizedBox(height: 20),
              const Text(
                "Zig Zag Blade Selected By",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: form.ZigZagBladeSelectedBy,
                enabled: false,
                decoration: InputDecoration(
                  hintText: "Will be filled automatically",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 26),

            // ✅ Rubber
            AddableSearchDropdown(
              label: "Rubber",
              items: form.jobs,
              initialValue: "No",
              onAdd: (newJob) => form.jobs.add(newJob),
              onChanged: (v) {
                setState(() {
                  form.RubberType.text = v ?? "";
                });

                String selected = (v ?? "").trim();

                if (selected.toLowerCase() == "no") {
                  form.RubberSelectedBy.clear();
                } else {
                  form.RubberSelectedBy.text = selectedByText(context);
                }
              },
            ),

            // ✅ Rubber Selected By
            if (isRubberSelected) ...[
              const SizedBox(height: 20),
              const Text(
                "Rubber Selected By",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: form.RubberSelectedBy,
                enabled: false,
                decoration: InputDecoration(
                  hintText: "Will be filled automatically",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 26),

            // ✅ Hole
            AddableSearchDropdown(
              label: "Hole",
              items: form.jobs,
              initialValue: "No",
              onAdd: (newJob) => form.jobs.add(newJob),
              onChanged: (v) {
                setState(() {
                  form.HoleType.text = v ?? "";
                });

                String selected = (v ?? "").trim();

                if (selected.toLowerCase() == "no") {
                  form.HoleSelectedBy.clear();
                } else {
                  form.HoleSelectedBy.text = selectedByText(context);
                }
              },
            ),

            // ✅ Hole Selected By
            if (isHoleSelected) ...[
              const SizedBox(height: 20),
              const Text(
                "Hole Selected By",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: form.HoleSelectedBy,
                enabled: false,
                decoration: InputDecoration(
                  hintText: "Will be filled automatically",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 30),

            // ✅ Emboss Toggle
            FlexibleToggle(
              label: "Emboss",
              inactiveText: "No",
              activeText: "Yes",
              onChanged: (v) {
                form.EmbossStatus.text = v ? "Yes" : "No";
              },
            ),

            const SizedBox(height: 26),

            TextInput(
              label: "Emboss Pcs",
              hint: "No of Pcs",
              controller: form.EmbossPcs,
              initialValue: "No",
            ),

            const SizedBox(height: 26),
          ],
        ),
      ),
    );
  }
}
