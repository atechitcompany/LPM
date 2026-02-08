import 'package:flutter/material.dart';
import 'package:lightatech/Production/JobCreation/screens/forms/new_form_scope.dart';
import 'package:lightatech/FormComponents/NumberStepper.dart';
import 'package:lightatech/FormComponents/AutoCalcTextbox.dart';

class AccountPage5Charges extends StatefulWidget {
  const AccountPage5Charges({super.key});

  @override
  State<AccountPage5Charges> createState() => _AccountPage5ChargesState();
}

class _AccountPage5ChargesState extends State<AccountPage5Charges> {
  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Capsule Rate
          const Text("Capsule Rate",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),

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

          // Capsule Pcs
          const Text("Capsule Pcs",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),

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

          // Creasing Rate
          const Text("Creasing Rate",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),

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

          // Perforation Size
          const Text("Perforation Size",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),

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

          // Zig-Zag Blade Size
          const Text("Zig-Zag Blade Size",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),

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

          // Rubber Size
          const Text("Rubber Size",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),

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

          // Hole Rate
          AutoCalcTextBox(label: "Hole Rate", value: "0"),
          const SizedBox(height: 30),

          // Holes
          const Text("Holes",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),

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

          // Courier Charges
          const Text("Courier Charges",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),

          NumberStepper(
            step: 0.01,
            initialValue: 0,
            controller: form.CourierCharges,
            onChanged: (val) {
              form.CourierCharges.text = val.toString();
              setState(() {});
            },
          ),

        ],
      ),
    );
  }
}
