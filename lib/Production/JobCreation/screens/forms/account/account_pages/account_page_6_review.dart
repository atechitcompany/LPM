import 'package:flutter/material.dart';
import 'package:lightatech/FormComponents/TextInput.dart';
import 'package:lightatech/FormComponents/NumberStepper.dart';
import 'package:lightatech/FormComponents/AutoCalcTextbox.dart';
import 'package:lightatech/FormComponents/FlexibleToggle.dart';
import 'package:lightatech/FormComponents/FlexibleSlider.dart';
import '../../new_form_scope.dart';

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

          // ===== EDIT FIELDS =====

          IgnorePointer(
            ignoring: false,
            child: Opacity(
              opacity: 1,
              child: TextInput(
                label: "Total Size",
                hint: "",
                controller: form.TotalSize,
              ),
            ),
          ),

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

          const SizedBox(height: 30),

          const Text(
            "Male Rate",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),

          IgnorePointer(
            ignoring: false,
            child: Opacity(
              opacity: 1,
              child: NumberStepper(
                step: 0.01,
                initialValue: double.tryParse(form.MaleRate.text) ?? 0,
                controller: form.MaleRate,
                onChanged: (val) {
                  form.MaleRate.text = val.toString();
                  setState(() {});
                },
              ),
            ),
          ),

          const SizedBox(height: 30),
          AutoCalcTextBox(label: "XY Size", value: "0"),
          const SizedBox(height: 30),
          AutoCalcTextBox(label: "Male Amount", value: "0"),
          const SizedBox(height: 30),

          const Text(
            "Female Rate",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),

          IgnorePointer(
            ignoring: false,
            child: Opacity(
              opacity: 1,
              child: NumberStepper(
                step: 0.01,
                initialValue: double.tryParse(form.FemaleRate.text) ?? 0,
                controller: form.FemaleRate,
                onChanged: (val) {
                  form.FemaleRate.text = val.toString();
                  setState(() {});
                },
              ),
            ),
          ),

          const SizedBox(height: 30),
          AutoCalcTextBox(label: "XY Size2", value: "0"),
          const SizedBox(height: 30),
          AutoCalcTextBox(label: "Female Amount", value: "0"),
          const SizedBox(height: 30),
          AutoCalcTextBox(label: "Stripping Amount", value: "0"),
          const SizedBox(height: 30),

          IgnorePointer(
            ignoring: false,
            child: Opacity(
              opacity: 1,
              child: FlexibleToggle(
                label: "Invoice",
                inactiveText: "Pending",
                activeText: "Done",
                initialValue: form.InvoiceStatus.text.toLowerCase() == "done",
                onChanged: (val) {
                  setState(() {
                    form.InvoiceStatus.text = val ? "Done" : "Pending";
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 30),

          IgnorePointer(
            ignoring: false,
            child: Opacity(
              opacity: 1,
              child: TextInput(
                label: "Invoice Printed By",
                hint: "Name",
                controller: form.InvoicePrintedBy,
              ),
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            "Particular",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),

          FlexibleSlider(
            max: 10,
            onChanged: (v) {
              form.ParticularSlider.text = v.toString();
            },
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}