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


class EmbossPage extends StatefulWidget {
  const EmbossPage({super.key});

  @override
  State<EmbossPage> createState() => _EmbossPageState();
}

class _EmbossPageState extends State<EmbossPage> {
  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Emboss"), backgroundColor: Colors.yellow,),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            //Party Name view access

            //Particular job name view access

            //LPM view access

            //Designing view access

            // Drawing attachment view access

            //Hole Amount View access

            //Emboss Edit access

            //Emboss pcs edit access

            //Male Emboss edit access

            //X Edit access

            //Y Edit Access

            //Female Embosse


          ],
        ),
      ),
    );
  }
}
