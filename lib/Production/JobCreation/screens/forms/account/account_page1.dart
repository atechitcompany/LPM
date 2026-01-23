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


class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text("Account"), backgroundColor: Colors.yellow,),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            //PartyName edit access

            //Designer Created by view access

            SearchableDropdownWithInitial(
              label: "Accounts Created By",
              items: form.parties,
              onChanged: (v) {},
            ),

            SizedBox(height: 30,),

            TextInput(
              controller: form.BuyerOrderNo,
              label: "Buyer's Order No",
              hint: "Order Number",
            ),

            SizedBox(height: 30,),

            //Delivery at edit access

            //Order by edit access

            //Particular Job name view access

            //LPM view access

            //Priority view access

            //Remark Edit Access

            //Designing View Access

            //Punch Report Edit Access

            TextInput(
              label: "Ups",
              hint: "ups",
              controller: form.Ups,
              initialValue: "NO",
            ),

            SizedBox(height: 30,),

            //Party Work name edit access

            TextInput(
              label: "Size",
              hint: "name",
              controller: form.Size,
              initialValue: "NO",
            ),

            const SizedBox(height: 30),

            TextInput(
              label: "Size2",
              hint: "name",
              controller: form.Size2,
              initialValue: "NO",
            ),

            const SizedBox(height: 30),

            TextInput(
              label: "Size3",
              hint: "name",
              controller: form.Size3,
              initialValue: "NO",
            ),

            const SizedBox(height: 30),

            TextInput(
              label: "Size4",
              hint: "name",
              controller: form.Size4,
              initialValue: "NO",
            ),

            const SizedBox(height: 30),

            TextInput(
              label: "Size5",
              hint: "name",
              controller: form.Size5,
              initialValue: "NO",
            ),

            const SizedBox(height: 30),

// Size Slider
            const Text(
              "Sizes",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),

            FlexibleSlider(
              max: 10,
              onChanged: (v) {},
            ),

            const SizedBox(height: 30),

// Ups_32 Stepper
            const Text(
              "Ups_32",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),

            NumberStepper(
              step: 1,
              initialValue: 0,
              controller: form.Ups_32,
              onChanged: (val) => print(val),
            ),

            const SizedBox(height: 30),

// Laser Cutting Punch New Toggle
            FlexibleToggle(
              label: "Laser Cutting Punch New",
              inactiveText: "No",
              activeText: "Yes",
              initialValue: false,
              onChanged: (val) {
                form.LaserPunchNew.text = val ? "Yes" : "No";
              },
            ),

            const SizedBox(height: 30),

            //Ply View Access

            //Ply Rate View Access

            const Text(
              "Ply Length",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),

              NumberStepper(
                step: 0.1,
                initialValue: 0.0,
                controller: form.PlyLength,
                onChanged: (val) {
                  form.PlyLength.text = val.toString();
                  setState(() {});
                },
              ),

              const SizedBox(height: 30),

              const Text(
                "Ply Breadth",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),

              NumberStepper(
                step: 0.1,
                initialValue: 0.0,
                controller: form.PlyBreadth,
                onChanged: (val) {
                  form.PlyBreadth.text = val.toString();
                  setState(() {});
                },
              ),

              const SizedBox(height: 30),

              AutoCalcTextBox(
                label: "Ply Size",
                value: (() {
                  double length = double.tryParse(form.PlyLength.text) ?? 0;
                  double breadth = double.tryParse(form.PlyBreadth.text) ?? 0;
                  double totalArea = length * breadth;

                  return totalArea.toStringAsFixed(1);
                })(),
              ),

              const SizedBox(height: 30),

              AutoCalcTextBox(label: "Ply Amount", value: "0"),

              const SizedBox(height: 30),

            //blade view access



          ],
        ),
      ),
    );
  }
}
