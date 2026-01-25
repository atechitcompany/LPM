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
          crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(height: 10,),

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
            const SizedBox(height: 10,),

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
            const SizedBox(height: 10,),

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
            const SizedBox(height: 10,),

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

            //blade yes/ no view access

            const Text(
              "Blade Size",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10,),

            NumberStepper(
              step: 1,
              initialValue: 0,
              controller: form.BladeSize,
              onChanged: (val) {
                form.BladeSize.text = val.toString();
                setState(() {});
              },
            ),
            const SizedBox(height: 30),

            AutoCalcTextBox(label: "Blade Amount", value: "0"),
            const SizedBox(height: 30),

            TextInput(
              label: "Extra",
              hint: "",
              controller: form.Extra,
              initialValue: "NO",
            ),

            const SizedBox(height: 30),

            const Text(
              "Capsule Rate",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10,),

            NumberStepper(
              step: 0.01,
              initialValue: 0,
              controller: form.CapsuleRate,
              onChanged: (val) {
                form.CapsuleRate.text = val.toString();
                setState(() {});
              },
            ),
            const SizedBox(height: 30),

            //Creasing Yes/No view access

            const Text(
              "Creasing Size",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10,),

            NumberStepper(
              step: 1,
              initialValue: 0,
              controller: form.CapsuleRate,
              onChanged: (val) {
                form.CapsuleRate.text = val.toString();
                setState(() {});
              },
            ),
            const SizedBox(height: 30),

            AutoCalcTextBox(label: "Creasing Amount", value: "0"),
            const SizedBox(height: 30),

            const Text(
              "Minimum Charges Applys",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10,),

            NumberStepper(
              step: 1,
              initialValue: 0,
              controller: form.MinimumChargeApply,
              onChanged: (val) {
                form.MinimumChargeApply.text = val.toString();
                setState(() {});
              },
            ),
            const SizedBox(height: 30),

            const Text(
              "Extra Slider",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10,),

            FlexibleSlider(
              max: 10,
              onChanged: (v) {},
            ),

            const SizedBox(height: 30),

//Micro sarration half cut 23.60 / Micro sarration Creasing  23.60

            SearchableDropdownWithInitial(
              label: "Delivery Created By",
              items: form.parties,
              onChanged: (v) {},
            ),

            SizedBox(height: 30,),

            SearchableDropdownWithInitial(
              label: "Delivery Created By",
              items: form.parties,
              onChanged: (v) {},
            ),

            SizedBox(height: 30,),
            FlexibleToggle(
              label: "Delivery",
              inactiveText: "Pending",
              activeText: "Done",
              initialValue: false,
              onChanged: (val) {
                form.DeliveryStatus.text = val ? "Yes" : "No";
              },
            ),
            SizedBox(height: 30,),

            const Text(
              "Die/Punch Image",
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

            const Text(
              "Invoice Image",
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

            TextInput(
              label: "Delivery URL",
              hint: "",
              controller: form.DeliveryURL,
              initialValue: "Delivered",
            ),

            const SizedBox(height: 30),

            FlexibleToggle(
              label: "Job Done",
              inactiveText: "No",
              activeText: "Yes",
              initialValue: false,
              onChanged: (val) {
                form.JobDone.text = val ? "Yes" : "No";
              },
            ),

            const SizedBox(height: 30),

            SearchableDropdownWithInitial(
              label: "Transport Name",
              items: form.parties,
              onChanged: (v) {},
            ),
            const SizedBox(height: 30),

            AddableSearchDropdown(
              label: "Delivery Address",
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

            TextInput(
              label: "Unknown",
              hint: "",
              controller: form.Unknown,
              initialValue: "NO",
            ),

            const SizedBox(height: 30),

            //Capsule Yes/No view access

            const Text(
              "Capsule Pcs",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10,),

            NumberStepper(
              step: 1,
              initialValue: 0,
              controller: form.CapsulePcs,
              onChanged: (val) {
                form.CapsulePcs.text = val.toString();
                setState(() {});
              },
            ),
            const SizedBox(height: 30),

            //Creasing Yes/No view access

            const Text(
              "Creasing Rate",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10,),

            NumberStepper(
              step: 1,
              initialValue: 0,
              controller: form.CapsuleRate,
              onChanged: (val) {
                form.CapsuleRate.text = val.toString();
                setState(() {});
              },
            ),
            const SizedBox(height: 30),

            AutoCalcTextBox(label: "Creasing Amount", value: "0"),
            const SizedBox(height: 30),

            //Perforation Amount view access

            const Text(
              "Perforation Size",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10,),

            NumberStepper(
              step: 1,
              initialValue: 0,
              controller: form.PerforationSize,
              onChanged: (val) {
                form.PerforationSize.text = val.toString();
                setState(() {});
              },
            ),
            const SizedBox(height: 30),

            AutoCalcTextBox(label: "Perforation Amount", value: "0"),
            const SizedBox(height: 30),

            //Zig-zag blade view access

            const Text(
              "Zig-Zag Blade Size",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10,),

            NumberStepper(
              step: 1,
              initialValue: 0,
              controller: form.ZigZagBladeSize,
              onChanged: (val) {
                form.ZigZagBladeSize.text = val.toString();
                setState(() {});
              },
            ),
            const SizedBox(height: 30),

            AutoCalcTextBox(label: "Zig Zag Blade Amount", value: "0"),
            const SizedBox(height: 30),

            //Rubber view/edit access

            const Text(
              "Rubber Size",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10,),

            NumberStepper(
              step: 1,
              initialValue: 0,
              controller: form.RubberSize,
              onChanged: (val) {
                form.RubberSize.text = val.toString();
                setState(() {});
              },
            ),
            const SizedBox(height: 30),

            AutoCalcTextBox(label: "Rubber Amount", value: "0"),
            const SizedBox(height: 30),

            //Hole view access
            AutoCalcTextBox(label: "Hole Rate", value: "0"),
            const SizedBox(height: 30),

            const Text(
              "Holes",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10,),

            NumberStepper(
              step: 1,
              initialValue: 0,
              controller: form.RubberSize,
              onChanged: (val) {
                form.RubberSize.text = val.toString();
                setState(() {});
              },
            ),
            const SizedBox(height: 30),

            AutoCalcTextBox(label: "Hole Amount", value: "0"),
            const SizedBox(height: 30),

            //Emboss view/edit access

            //Emboss Pcs view access

            TextInput(
              label: "Total Size",
              hint: "",
              controller: form.TotalSize,
              initialValue: "NO",
            ),

            const SizedBox(height: 30),

            const Text(
              "Minimum Charges Apply",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10,),

            NumberStepper(
              step: 1,
              initialValue: 0,
              controller: form.MinimumChargeApply,
              onChanged: (val) {
                form.MinimumChargeApply.text = val.toString();
                setState(() {});
              },
            ),
            const SizedBox(height: 30),

            //Male emboss view access

            const Text(
              "Male Rate",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10,),

            NumberStepper(
              step: 0.01,
              initialValue: 0,
              controller: form.MaleRate,
              onChanged: (val) {
                form.MaleRate.text = val.toString();
                setState(() {});
              },
            ),
            const SizedBox(height: 30),

            //X,Y view/edit access

            //add formula using X,Y values from above comment
            AutoCalcTextBox(label: "XY Size", value: "0"),
            const SizedBox(height: 30),

            AutoCalcTextBox(label: "Male Amount", value: "0"),
            const SizedBox(height: 30),

            //Female Emboss View access

            const Text(
              "Female Rate",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10,),

            NumberStepper(
              step: 0.01,
              initialValue: 0,
              controller: form.FemaleRate,
              onChanged: (val) {
                form.FemaleRate.text = val.toString();
                setState(() {});
              },
            ),
            const SizedBox(height: 30),

            //X2,Y2 view/edit access

            //add formula using X2,Y2 values from above comment
            AutoCalcTextBox(label: "XY Size2", value: "0"),
            const SizedBox(height: 30),

            AutoCalcTextBox(label: "Female Amount", value: "0"),
            const SizedBox(height: 30),

            //Stripping view access

            AutoCalcTextBox(label: "Stripping Amount", value: "0"),
            const SizedBox(height: 30),

            const Text(
              "Courier Charges",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10,),

            NumberStepper(
              step: 0.01,
              initialValue: 0,
              controller: form.CourierCharges,
              onChanged: (val) {
                form.CourierCharges.text = val.toString();
                setState(() {});
              },
            ),
            const SizedBox(height: 30),

            //Laser Cutting Status view/edit access

            FlexibleToggle(
              label: "Invoice",
              inactiveText: "No",
              activeText: "Yes",
              initialValue: false,
              onChanged: (val) {
                form.InvoiceStatus.text = val ? "Yes" : "No";
              },
            ),
            const SizedBox(height: 30),

            TextInput(
              label: "Invoice Printed By",
              hint: "Name",
              controller: form.InvoicePrintedBy,
              initialValue: "",
            ),

            const SizedBox(height: 30),

            const Text(
              "Particular",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10,),

            FlexibleSlider(
              max: 10,
              onChanged: (v) {},
            ),

            const SizedBox(height: 30),













          ],
        ),
      ),
    );
  }
}
