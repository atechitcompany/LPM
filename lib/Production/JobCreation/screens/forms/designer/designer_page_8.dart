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


class DesignerPage8 extends StatelessWidget {
  const DesignerPage8({super.key});

  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Designer 8"), backgroundColor: Colors.yellow),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextInput(
              label: "Laser Done By",
              hint: "Name",
              controller: form.LaserDoneBy,
            ),
            const SizedBox(
              height: 30,
            ),

            AddableSearchDropdown(
              label: "Stripping",
              items: form.jobs,
              onChanged: (v) {
                form.StrippingType.text = v ?? "";
              },
              onAdd: (newJob) => form.jobs.add(newJob),
              initialValue: "No",
            ),

            const SizedBox(height: 30),

            FlexibleToggle(
              label: "Laser Cutting Status",
              inactiveText: "Pending",
              activeText: "Done",
              onChanged: (v) {
                form.LaserCuttingStatus.text = v ? "Done" : "Pending";
              },
            ),

            const SizedBox(height: 30),


            TextInput(
              label: "AutoBending Done By",
              hint: "Name",
              controller: form.AutoBendingDoneBy,
            ),
            const SizedBox(
              height: 30,
            ),
          ],
        ),
      ),
    );
  }
}
