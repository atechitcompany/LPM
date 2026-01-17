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


class DesignerPage5 extends StatelessWidget {
  const DesignerPage5({super.key});

  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Designer 5"), backgroundColor: Colors.yellow),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AddableSearchDropdown(
              label: "Transport Name",
              items: form.jobs,
              onChanged: (v) {
                form.TransportName.text = v ?? "";
              },
              onAdd: (newJob) => form.jobs.add(newJob),
            ),

            const SizedBox(height: 30),

            AddableSearchDropdown(
              label: "House No",
              items: form.HouseNoList,
              onChanged: (v) {
                form.HouseNo = v;
                form.updateAddress();
              },
              onAdd: (newValue) {
                form.HouseNoList.add(newValue);
                form.HouseNo = newValue;
                form.updateAddress();
              },
            ),

            const SizedBox(height: 30),

            AddableSearchDropdown(
              label: "Appartment",
              items: form.AppartmentList,
              onChanged: (v) {
                form.Appartment = v;
                form.updateAddress();
              },
              onAdd: (newValue) {
                form.AppartmentList.add(newValue);
                form.Appartment = newValue;
                form.updateAddress();
              },
            ),

            const SizedBox(height: 30),

            AddableSearchDropdown(
              label: "Street",
              items: form.StreetList,
              onChanged: (v) {
                form.Street = v;
                form.updateAddress();
              },
              onAdd: (newValue) {
                form.StreetList.add(newValue);
                form.Street = newValue;
                form.updateAddress();
              },
            ),

            const SizedBox(height: 30),

            AddableSearchDropdown(
              label: "Pincode",
              items: form.PincodeList,
              onChanged: (v) {
                form.Pincode = v;
                form.updateAddress();
              },
              onAdd: (newValue) {
                form.PincodeList.add(newValue);
                form.Pincode = newValue;
                form.updateAddress();
              },
            ),

            const SizedBox(height: 30),

            AutoCalcTextBox(
              label: "Full Address",
              controller: form.AddressOutput,
            ),

            const SizedBox(height: 30),


          ],
        ),
      ),
    );
  }
}
