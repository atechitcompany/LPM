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

class DesignerPage1 extends StatefulWidget {
  const DesignerPage1({super.key});

  @override
  State<DesignerPage1> createState() => _DesignerPage1State();
}

class _DesignerPage1State extends State<DesignerPage1> {
  String? manualBendingCreatedBy;
  bool manualBendingDone = false; // ✅ Toggle value

  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Designer1"),
        backgroundColor: Colors.yellow,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SearchableDropdownWithInitial(
              label: "Party Name *",
              items: form.parties,
              onChanged: (v) {},
            ),

            const SizedBox(height: 30),

            SearchableDropdownWithInitial(
              label: "Designer Created By",
              items: form.parties,
              onChanged: (v) {
                form.DesignerCreatedBy.text = v ?? "";
              },
            ),

            const SizedBox(height: 30),

            SearchableDropdownWithInitial(
              label: "Emboss Created By",
              items: form.parties,
              onChanged: (v) {},
            ),

            const SizedBox(height: 30),

            SearchableDropdownWithInitial(
              label: "Manual Bending Created By",
              items: form.parties,
              onChanged: (v) {
                setState(() {
                  manualBendingCreatedBy = v;

                  // ✅ Optional: reset toggle whenever new person selected
                  manualBendingDone = false;
                });
              },
            ),

            // ✅ Toggle appears only after dropdown selection
            if (manualBendingCreatedBy != null &&
                manualBendingCreatedBy!.isNotEmpty) ...[
              const SizedBox(height: 15),

              FlexibleToggle(
                label: "Manual Bending Status",
                inactiveText: "Pending",
                activeText: "Done",
                initialValue: manualBendingDone,
                onChanged: (val) {
                  setState(() {
                    manualBendingDone = val;
                  });
                },
              ),
            ],

            const SizedBox(height: 30),

            TextInput(
              controller: form.DeliveryAt,
              label: "Delivery At",
              hint: "Address",
            ),

            const SizedBox(height: 30),

            TextInput(
              controller: form.Orderby,
              label: "Order By",
              hint: "Name",
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
