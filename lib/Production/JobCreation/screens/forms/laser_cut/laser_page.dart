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


class LaserPage extends StatefulWidget {
  const LaserPage({super.key});

  @override
  State<LaserPage> createState() => _LaserPageState();
}

class _LaserPageState extends State<LaserPage> {
  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Lasercut"), backgroundColor: Colors.yellow),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FlexibleToggle(
              label: "Laser Cutting Punch New",
              inactiveText: "No",
              activeText: "Yes",
              initialValue: false,
              onChanged: (val) {
                form.LaserPunchNew.text = val ? "Yes" : "No";
              },
            ),

            //Particular Job name View access

            //LPM View access

            SizedBox(height: 30,),

            //Ply View Access





          ],
        ),
      ),
    );
  }
}
