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


class DesignerPage2 extends StatelessWidget {
  const DesignerPage2({super.key});

  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);
    return Scaffold(
        backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Designer 2"), backgroundColor: Colors.yellow),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            AddableSearchDropdown(
              label: "Particular Job Name *",
              items: form.jobs,
              onChanged: (v) {},
              onAdd: (newJob) => form.jobs.add(newJob),
            ),

            const SizedBox(height: 30),

            AutoIncrementField(value: 1004),

            const SizedBox(height: 30),

            const Text(
              "Priority",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, ),
            ),

            PrioritySelector(
              onChanged: (v) {
                form.Priority.text = v ?? "";
              },
            ),

            const SizedBox(height: 30),

            TextInput(
              label: "Remark",
              hint: "Remark",
              controller: form.Remark,
              initialValue: "NO REMARK",
            ),

            const SizedBox(height: 30),

            FlexibleToggle(
              label: "Designing *",
              inactiveText: "Pending",
              activeText: "Done",
              initialValue: false,
              onChanged: (val) {
                form.DesigningStatus.text = val ? "Done" : "Pending";
              },
            ),

            const SizedBox(height: 30),

            // Drawing Attachment
            const Text(
              "Drawing Attachment",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),

            FileUploadBox(
              onFileSelected: (file) {
                print("Selected File: ${file.name}");
                print("Size: ${file.size}");
                print("Path: ${file.path}");
              },
            ),

            const SizedBox(height: 30),


          ],
        ),
      ),
    );
  }
}
