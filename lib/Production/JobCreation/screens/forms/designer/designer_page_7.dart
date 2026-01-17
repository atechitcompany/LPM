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


class DesignerPage7 extends StatelessWidget {
  const DesignerPage7({super.key});

  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Designer 7"), backgroundColor: Colors.yellow),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            AddableSearchDropdown(
              label: "Male Emboss",
              items: form.jobs,
              onChanged: (v) {
                form.MaleEmbossType.text = v ?? "";
              },
              onAdd: (newJob) => form.jobs.add(newJob),
              initialValue: "No",
            ),

            const SizedBox(height: 30),

            const Text(
              "X",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),

            NumberStepper(
              step: 0.01,
              onChanged: (val) {
                form.X.text = val.toString();
                form.calculateXY();
              },
              controller: form.X,
            ),

            const SizedBox(height: 30),

            const Text(
              "Y",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),

            NumberStepper(
              step: 0.01,
              onChanged: (val) {
                form.Y.text = val.toString();
                form.calculateXY();
              },
              controller: form.Y,
            ),

            const SizedBox(height: 30),

            AddableSearchDropdown(
              label: "Female Emboss",
              items: form.jobs,
              onChanged: (v) {
                form.FemaleEmbossType.text = v ?? "";
              },
              onAdd: (newJob) => form.jobs.add(newJob),
              initialValue: "No",
            ),

            const SizedBox(height: 30),

            const Text(
              "X2",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),

            NumberStepper(
              step: 0.01,
              onChanged: (val) {
                form.X2.text = val.toString();
                form.calculateXY();
              },
              controller: form.X2,
            ),

            const SizedBox(height: 30),

            const Text(
              "Y2",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),

            NumberStepper(
              step: 0.01,
              onChanged: (val) {
                form.Y2.text = val.toString();
                form.calculateXY2();
              },
              controller: form.Y2,
            ),

            const SizedBox(height: 30),

          ],
        ),
      ),
    );
  }
}
