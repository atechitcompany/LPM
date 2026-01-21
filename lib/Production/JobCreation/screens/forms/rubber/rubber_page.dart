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


class RubberPage extends StatefulWidget {
  const RubberPage({super.key});

  @override
  State<RubberPage> createState() => _RubberPageState();
}

class _RubberPageState extends State<RubberPage> {
  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);
    return Scaffold(
      backgroundColor: Colors.yellow,
      appBar: AppBar(title: const Text("Rubber"),backgroundColor: Colors.white,),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            //Party Name View access

            //Particular Job Name

            //LPM View Access

          ],
        ),
      ),
    );
  }
}
