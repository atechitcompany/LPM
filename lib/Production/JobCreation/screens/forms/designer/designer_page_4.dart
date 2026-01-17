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
            TextInput(
              label: "Manual Bending Fitting Done By",
              hint: "Name",
              controller: form.ManualBendingFittingDoneBy,
            ),
            const SizedBox(
              height: 26,
            ),

            SearchableDropdownWithInitial(
              label: "Delivery Created By",
              items: form.ply,
              onChanged: (v) {
                form.DeliveryCreatedBy.text = v ?? "";
              },
            ),

            const SizedBox(height: 26),

            FlexibleToggle(
              label: "Delivery",
              inactiveText: "Pending",
              activeText: "Done",
              initialValue: false,
              onChanged: (val) {
                form.DeliveryStatus.text = val ? "Done" : "Pending";
              },
            ),

            const SizedBox(height: 26),

            const Text(
              "Die/Punch Image",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),

            FileUploadBox(
              onFileSelected: (file) {},
            ),

            const SizedBox(height: 26),

            const Text(
              "Invoice Image",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),

            FileUploadBox(
              onFileSelected: (file) {},
            ),

            const SizedBox(height: 26),

            TextInput(
              label: "Delivery URL",
              hint: "URL",
              controller: form.DeliveryURL,
              initialValue: "URL",
            ),

            const SizedBox(height: 26),

            FlexibleToggle(
              label: "Job Done",
              inactiveText: "No",
              activeText: "Yes",
              onChanged: (v) {
                // Store toggle value if needed
              },
            ),

            const SizedBox(height: 26),
          ],
        ),
      ),
    );
  }
}
