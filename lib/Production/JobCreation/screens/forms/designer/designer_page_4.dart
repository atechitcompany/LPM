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
  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);

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
            AddableSearchDropdown(
              label: "Perforation",
              items: form.jobs,
              onChanged: (v) {},
              onAdd: (newJob) => form.jobs.add(newJob),
              initialValue: "No",
            ),

            const SizedBox(height: 26),

            AddableSearchDropdown(
              label: "Zig Zag Blade",
              items: form.jobs,
              onChanged: (v) {
                form.ZigZagBlade.text = v ?? "";
              },
              onAdd: (newJob) => form.jobs.add(newJob),
              initialValue: "No",
            ),

            const SizedBox(height: 26),

            AddableSearchDropdown(
              label: "Rubber",
              items: form.jobs,
              onChanged: (v) {
                form.RubberType.text = v ?? "";
              },
              onAdd: (newJob) => form.jobs.add(newJob),
              initialValue: "No",
            ),

            const SizedBox(height: 26),

            AddableSearchDropdown(
              label: "Hole",
              items: form.jobs,
              onChanged: (v) {
                form.HoleType.text = v ?? "";
              },
              onAdd: (newJob) => form.jobs.add(newJob),
              initialValue: "No",
            ),

            const SizedBox(height: 30),

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
