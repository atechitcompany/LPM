import 'package:flutter/material.dart';
import 'package:lightatech/FormComponents/FlexibleToggle.dart';
import 'package:lightatech/FormComponents/NumberStepper.dart';
import 'package:lightatech/FormComponents/AutoCalcTextbox.dart';
import '../../new_form_scope.dart';

class AccountPage3Ply extends StatefulWidget {
  const AccountPage3Ply({super.key});

  @override
  State<AccountPage3Ply> createState() => _AccountPage3PlyState();
}

class _AccountPage3PlyState extends State<AccountPage3Ply> {
  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);

    final double length = double.tryParse(form.PlyLength.text) ?? 0;
    final double breadth = double.tryParse(form.PlyBreadth.text) ?? 0;
    final double totalArea = length * breadth;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ===== EDIT FIELDS =====

          IgnorePointer(
            ignoring: false,
            child: Opacity(
              opacity: 1,
              child: FlexibleToggle(
                label: "Laser Cutting Punch New",
                inactiveText: "No",
                activeText: "Yes",
                initialValue: form.LaserPunchNew.text.toLowerCase() == "yes",
                onChanged: (val) {
                  setState(() {
                    form.LaserPunchNew.text = val ? "Yes" : "No";
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            "Ply Length",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),

          IgnorePointer(
            ignoring: false,
            child: Opacity(
              opacity: 1,
              child: NumberStepper(
                step: 0.1,
                initialValue: length,
                controller: form.PlyLength,
                onChanged: (val) {
                  form.PlyLength.text = val.toString();
                  setState(() {});
                },
              ),
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            "Ply Breadth",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),

          IgnorePointer(
            ignoring: false,
            child: Opacity(
              opacity: 1,
              child: NumberStepper(
                step: 0.1,
                initialValue: breadth,
                controller: form.PlyBreadth,
                onChanged: (val) {
                  form.PlyBreadth.text = val.toString();
                  setState(() {});
                },
              ),
            ),
          ),

          const SizedBox(height: 30),

          AutoCalcTextBox(
            label: "Ply Size",
            value: totalArea.toStringAsFixed(1),
          ),

          const SizedBox(height: 30),

          AutoCalcTextBox(
            label: "Ply Amount",
            value: "0",
          ),

          const SizedBox(height: 30),

          const Text(
            "Blade Size",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),

          IgnorePointer(
            ignoring: false,
            child: Opacity(
              opacity: 1,
              child: NumberStepper(
                step: 1,
                initialValue: double.tryParse(form.BladeSize.text) ?? 0,
                controller: form.BladeSize,
                onChanged: (val) {
                  form.BladeSize.text = val.toString();
                  setState(() {});
                },
              ),
            ),
          ),

          const SizedBox(height: 30),

          AutoCalcTextBox(label: "Blade Amount", value: "0"),

          const SizedBox(height: 30),

          const Text(
            "Creasing Size",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),

          IgnorePointer(
            ignoring: false,
            child: Opacity(
              opacity: 1,
              child: NumberStepper(
                step: 1,
                initialValue: double.tryParse(form.CreasingSize.text) ?? 0,
                controller: form.CreasingSize,
                onChanged: (val) {
                  form.CreasingSize.text = val.toString();
                  setState(() {});
                },
              ),
            ),
          ),

          const SizedBox(height: 30),

          AutoCalcTextBox(label: "Creasing Amount", value: "0"),

          const SizedBox(height: 30),

          const Text(
            "Minimum Charges Apply",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),

          IgnorePointer(
            ignoring: false,
            child: Opacity(
              opacity: 1,
              child: NumberStepper(
                step: 1,
                initialValue: double.tryParse(form.MinimumChargeApply.text) ?? 0,
                controller: form.MinimumChargeApply,
                onChanged: (val) {
                  form.MinimumChargeApply.text = val.toString();
                  setState(() {});
                },
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}