import 'package:flutter/material.dart';
import 'package:lightatech/Production/JobCreation/screens/forms/new_form_scope.dart';
import 'package:lightatech/FormComponents/FlexibleToggle.dart';
import 'package:lightatech/FormComponents/NumberStepper.dart';
import 'package:lightatech/FormComponents/AutoCalcTextbox.dart';

class AccountPage3Ply extends StatelessWidget {
  const AccountPage3Ply({super.key});

  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);

    double length = double.tryParse(form.PlyLength.text) ?? 0;
    double breadth = double.tryParse(form.PlyBreadth.text) ?? 0;
    double totalArea = length * breadth;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Laser Cutting Punch New
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

          // Ply Length
          const Text(
            "Ply Length",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),

          NumberStepper(
            step: 0.1,
            initialValue: 0.0,
            controller: form.PlyLength,
            onChanged: (val) {
              form.PlyLength.text = val.toString();
            },
          ),

          const SizedBox(height: 30),

          // Ply Breadth
          const Text(
            "Ply Breadth",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),

          NumberStepper(
            step: 0.1,
            initialValue: 0.0,
            controller: form.PlyBreadth,
            onChanged: (val) {
              form.PlyBreadth.text = val.toString();
            },
          ),

          const SizedBox(height: 30),

          // Ply Size (Auto Calculated)
          AutoCalcTextBox(
            label: "Ply Size",
            value: totalArea.toStringAsFixed(1),
          ),

          const SizedBox(height: 30),

          // Ply Amount
          AutoCalcTextBox(
            label: "Ply Amount",
            value: "0",
          ),

          const SizedBox(height: 30),

          // Blade Size
          const Text(
            "Blade Size",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),

          NumberStepper(
            step: 1,
            initialValue: 0,
            controller: form.BladeSize,
            onChanged: (val) {
              form.BladeSize.text = val.toString();
            },
          ),

          const SizedBox(height: 30),

          // Blade Amount
          AutoCalcTextBox(
            label: "Blade Amount",
            value: "0",
          ),

          const SizedBox(height: 30),

          // Creasing Size
          const Text(
            "Creasing Size",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),

          NumberStepper(
            step: 1,
            initialValue: 0,
            controller: form.CapsuleRate, // same as original code
            onChanged: (val) {
              form.CapsuleRate.text = val.toString();
            },
          ),

          const SizedBox(height: 30),

          // Creasing Amount
          AutoCalcTextBox(
            label: "Creasing Amount",
            value: "0",
          ),

          const SizedBox(height: 30),

          // Minimum Charges Apply
          const Text(
            "Minimum Charges Applys",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),

          NumberStepper(
            step: 1,
            initialValue: 0,
            controller: form.MinimumChargeApply,
            onChanged: (val) {
              form.MinimumChargeApply.text = val.toString();
            },
          ),

        ],
      ),
    );
  }
}
