import 'package:flutter/material.dart';
import 'package:lightatech/Production/JobCreation/screens/forms/new_form_scope.dart';
import 'package:lightatech/FormComponents/TextInput.dart';
import 'package:lightatech/FormComponents/NumberStepper.dart';
import 'package:lightatech/FormComponents/AutoCalcTextbox.dart';
import 'package:lightatech/FormComponents/FlexibleToggle.dart';
import 'package:lightatech/FormComponents/FlexibleSlider.dart';

class AccountPage6Review extends StatefulWidget {
  const AccountPage6Review({super.key});

  @override
  State<AccountPage6Review> createState() => _AccountPage6ReviewState();
}

class _AccountPage6ReviewState extends State<AccountPage6Review> {
  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Total Size
          TextInput(
            label: "Total Size",
            hint: "",
            controller: form.TotalSize,
            initialValue: "NO",
          ),

          const SizedBox(height: 30),

          // Minimum Charges Apply
          const Text(
            "Minimum Charges Apply",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),

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

          // Male Rate
          const Text(
            "Male Rate",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),

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

          AutoCalcTextBox(label: "XY Size", value: "0"),
          const SizedBox(height: 30),

          AutoCalcTextBox(label: "Male Amount", value: "0"),
          const SizedBox(height: 30),

          // Female Rate
          const Text(
            "Female Rate",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),

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

          AutoCalcTextBox(label: "XY Size2", value: "0"),
          const SizedBox(height: 30),

          AutoCalcTextBox(label: "Female Amount", value: "0"),
          const SizedBox(height: 30),

          // Stripping Amount
          AutoCalcTextBox(label: "Stripping Amount", value: "0"),
          const SizedBox(height: 30),

          // Invoice Toggle
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

          // Invoice Printed By
          TextInput(
            label: "Invoice Printed By",
            hint: "Name",
            controller: form.InvoicePrintedBy,
            initialValue: "",
          ),

          const SizedBox(height: 30),

          // Particular Slider
          const Text(
            "Particular",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),

          FlexibleSlider(
            max: 10,
            onChanged: (v) {},
          ),

        ],
      ),
    );
  }
}
