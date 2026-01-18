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


class AutoBendingPage extends StatefulWidget {
  const AutoBendingPage({super.key});

  @override
  State<AutoBendingPage> createState() => _AutoBendingPageState();
}

class _AutoBendingPageState extends State<AutoBendingPage> {
  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Autobending"),
        backgroundColor: Colors.yellow,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            //Partyname view access


            SearchableDropdownWithInitial(
              label: "Auto Bending Created By",
              items: form.parties,
              onChanged: (v) {},
            ),

              const SizedBox(height: 30),

            //Delivery at edit access

            //Particular job name view access

            //LPM number view access

            //priority view access

            //Remark edit access

            //Designing edit access

            //Drawing Attachment edit access

            //Punch report Edit access

            //partywork name ask Akash sir

            //Blade view access

            //Transport name Ask Akash sir

            //unknown edit access

            //Rubber edit access

            //Hole edit access

            FlexibleToggle(label: "Auto Creasing ", inactiveText: "No", activeText: "Yes", onChanged: (v){setState(() {
              form.AutoCreasing = v;
            });}),


            if (form.AutoCreasing) ...[
              const SizedBox(height: 30),
              FlexibleToggle(
                label: "Auto Creasing Status",
                inactiveText: "Pending",
                activeText: "Done",
                onChanged: (v) {
                  // handle status change here
                },
              ),
            ],

            SizedBox(height: 30,),

            //Laser cutting status edit access

          ],
        ),
      ),
    );
  }
}
