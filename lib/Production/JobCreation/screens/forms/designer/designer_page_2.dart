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

class DesignerPage2 extends StatefulWidget {
  const DesignerPage2({super.key});

  @override
  State<DesignerPage2> createState() => _DesignerPage2State();
}

class _DesignerPage2State extends State<DesignerPage2> {
  bool isDesigningDone = false;

  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);
    bool isPlySelected = form.PlyType.text.trim().toLowerCase() != "no";


    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Designer 2"),
        backgroundColor: Colors.yellow,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Priority",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
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

            /// ✅ Designing Toggle
            FlexibleToggle(
              label: "Designing *",
              inactiveText: "Pending",
              activeText: "Done",
              initialValue: isDesigningDone,
              onChanged: (val) {
                setState(() {
                  isDesigningDone = val;
                });

                form.DesigningStatus.text = val ? "Done" : "Pending";

                // ✅ Keep DesignedBy empty for now when set back to pending
                if (!val) {
                  form.DesignedBy.clear();
                }
              },
            ),


            const SizedBox(height: 30),

            // Drawing Attachment
            const Text(
              "Drawing Attachment",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),

            FileUploadBox(
              onFileSelected: (file) {
                print("Selected File: ${file.name}");
                print("Size: ${file.size}");
                print("Path: ${file.path}");
              },
            ),
            const SizedBox(height: 30),

            /// ✅ Show "Designed By" only when Designing is Done
            if (isDesigningDone) ...[

              const Text(
                "Rubber Report",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),

              FileUploadBox(
                onFileSelected: (file) {
                  print("Selected File: ${file.name}");
                  print("Size: ${file.size}");
                  print("Path: ${file.path}");
                },
              ),
              const SizedBox(height: 30),
            ],


            const Text(
              "Punch Report",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),

            FileUploadBox(
              onFileSelected: (file) {
                print("Selected File: ${file.name}");
                print("Size: ${file.size}");
                print("Path: ${file.path}");
              },
            ),

            const SizedBox(height: 30),

            AddableSearchDropdown(
              label: "Ply",
              items: form.ply,
              initialValue: "No",
              onChanged: (v) {
                setState(() {
                  form.PlyType.text = v ?? "";
                });

                String selected = (v ?? "").trim();

                // ✅ If Ply is "No" → hide & clear
                if (selected.toLowerCase() == "no") {
                  form.PlySelectedBy.clear();
                  return;
                }

                // ✅ If Ply is selected (not No) → auto-fill PlySelectedBy
                form.PlySelectedBy.text =
                "Company on ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} at ${TimeOfDay.now().format(context)}";
              },

              onAdd: (v) => form.ply.add(v),
            ),
            /// ✅ Show "Ply Selected By" only when Ply is selected (not "No")
            if (isPlySelected) ...[
              const SizedBox(height: 30),

              const Text(
                "Ply Selected By",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: form.PlySelectedBy,
                enabled: false,
                decoration: InputDecoration(
                  hintText: "Will be filled automatically",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],



          ],
        ),
      ),
    );
  }
}
