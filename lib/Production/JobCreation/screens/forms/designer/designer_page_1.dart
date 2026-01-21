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
  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Designer 1"),
        backgroundColor: Colors.yellow,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Party Name stored properly
            SearchableDropdownWithInitial(
              label: "Party Name *",
              items: form.parties,
              initialValue: form.PartyName.text.isEmpty
                  ? "Select Party"
                  : form.PartyName.text,
              onChanged: (v) {
                setState(() {
                  form.PartyName.text = (v ?? "").trim();
                });
              },
            ),

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

            // ✅ Particular Job Name stored properly
            AddableSearchDropdown(
              label: "Particular Job Name *",
              items: form.jobs,
              initialValue: form.ParticularJobName.text.isEmpty
                  ? "No"
                  : form.ParticularJobName.text,
              onChanged: (v) {
                setState(() {
                  form.ParticularJobName.text = (v ?? "").trim();
                });
              },
              onAdd: (newJob) => form.jobs.add(newJob),
            ),

            const SizedBox(height: 30),

            // ✅ LPM Auto Increment (from Firebase)
            ValueListenableBuilder(
              valueListenable: form.LpmAutoIncrement,
              builder: (context, value, child) {
                return AutoIncrementField(
                  value: int.tryParse(form.LpmAutoIncrement.text) ?? 0,
                );
              },
            ),




            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

