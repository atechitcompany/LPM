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

class DesignerPage3 extends StatefulWidget {
  const DesignerPage3({super.key});

  @override
  State<DesignerPage3> createState() => _DesignerPage3State();
}

class _DesignerPage3State extends State<DesignerPage3> {
  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);

    bool isBladeSelected = form.Blade.text.trim().toLowerCase() != "no";
    bool isCreasingSelected = form.Creasing.text.trim().toLowerCase() != "no";

    String selectedByText() {
      return "Company on ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} at ${TimeOfDay.now().format(context)}";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Designer 3"),
        backgroundColor: Colors.yellow,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Blade Dropdown
            SearchableDropdownWithInitial(
              label: "Blade",
              items: form.ply,
              initialValue: "No",
              onChanged: (v) {
                setState(() {
                  form.Blade.text = v ?? "";
                });

                String selected = (v ?? "").trim();

                if (selected.toLowerCase() == "no") {
                  form.BladeSelectedBy.clear();
                } else {
                  form.BladeSelectedBy.text = selectedByText();
                }
              },
            ),

            /// ✅ Blade Selected By (only when Blade != No)
            if (isBladeSelected) ...[
              const SizedBox(height: 20),
              const Text(
                "Blade Selected By",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: form.BladeSelectedBy,
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

            // ✅ Creasing Dropdown
            SearchableDropdownWithInitial(
              label: "Creasing",
              items: form.ply,
              initialValue: "No",
              onChanged: (v) {
                setState(() {
                  form.Creasing.text = v ?? "";
                });

                String selected = (v ?? "").trim();

                if (selected.toLowerCase() == "no") {
                  form.CreasingSelectedBy.clear();
                } else {
                  form.CreasingSelectedBy.text = selectedByText();
                }
              },
            ),

            /// ✅ Creasing Selected By (only when Creasing != No)
            if (isCreasingSelected) ...[
              const SizedBox(height: 20),
              const Text(
                "Creasing Selected By",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: form.CreasingSelectedBy,
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

            // ✅ Toggles
            FlexibleToggle(
              label: "Micro sarration Half cut 23.60",
              inactiveText: "No",
              activeText: "Yes",
              initialValue: false,
              onChanged: (val) {},
            ),

            const SizedBox(height: 30),

            FlexibleToggle(
              label: "Micro sarration Creasing 23.60",
              inactiveText: "No",
              activeText: "Yes",
              initialValue: false,
              onChanged: (val) {},
            ),

            const SizedBox(height: 30),

            TextInput(
              label: "Unknown",
              hint: "Unknown",
              controller: form.Unknown,
            ),

            const SizedBox(height: 26),

            AddableSearchDropdown(
              label: "Capsule",
              items: form.jobs,
              onChanged: (v) {
                form.CapsuleType.text = v ?? "";
              },
              onAdd: (newJob) => form.jobs.add(newJob),
              initialValue: "No",
            ),

            const SizedBox(height: 26),
          ],
        ),
      ),
    );
  }
}

