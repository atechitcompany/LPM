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


class DesignerPage3 extends StatelessWidget {
  const DesignerPage3({super.key});

  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Designer 3"), backgroundColor: Colors.yellow),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Punch Report
            const Text(
              "Punch Report",
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
