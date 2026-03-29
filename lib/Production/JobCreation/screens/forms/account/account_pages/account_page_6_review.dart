import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
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

          // ===== CONTROLLED EDIT FIELDS =====

          if (form.canView("TotalSize")) ...[
            IgnorePointer(
              ignoring: !form.canEdit("TotalSize"),
              child: Opacity(
                opacity: form.canEdit("TotalSize") ? 1 : 0.6,
                child: TextInput(
                  label: "Total Size",
                  hint: "",
                  controller: form.TotalSize,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],

          if (form.canView("MinimumChargeApply")) ...[
            const Text(
              "Minimum Charges Apply",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            IgnorePointer(
              ignoring: !form.canEdit("MinimumChargeApply"),
              child: Opacity(
                opacity: form.canEdit("MinimumChargeApply") ? 1 : 0.6,
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
          ],

          if (form.canView("MaleRate")) ...[
            const Text(
              "Male Rate",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            IgnorePointer(
              ignoring: !form.canEdit("MaleRate"),
              child: Opacity(
                opacity: form.canEdit("MaleRate") ? 1 : 0.6,
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
          ],

          // ===== FREE UI (AUTOCALC) =====
          AutoCalcTextBox(label: "XY Size", value: "0"),
          const SizedBox(height: 30),
          AutoCalcTextBox(label: "Male Amount", value: "0"),
          const SizedBox(height: 30),

          // ===== CONTROLLED EDIT FIELDS =====

          if (form.canView("FemaleRate")) ...[
            const Text(
              "Female Rate",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            IgnorePointer(
              ignoring: !form.canEdit("FemaleRate"),
              child: Opacity(
                opacity: form.canEdit("FemaleRate") ? 1 : 0.6,
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
          ],

          // ===== FREE UI (AUTOCALC) =====
          AutoCalcTextBox(label: "XY Size2", value: "0"),
          const SizedBox(height: 30),
          AutoCalcTextBox(label: "Female Amount", value: "0"),
          const SizedBox(height: 30),
          AutoCalcTextBox(label: "Stripping Amount", value: "0"),
          const SizedBox(height: 30),

          // ===== CONTROLLED EDIT FIELDS =====

          if (form.canView("InvoiceStatus")) ...[
            IgnorePointer(
              ignoring: !form.canEdit("InvoiceStatus"),
              child: Opacity(
                opacity: form.canEdit("InvoiceStatus") ? 1 : 0.6,
                child: FlexibleToggle(
                  label: "Invoice",
                  inactiveText: "Pending",
                  activeText: "Done",
                  initialValue: form.InvoiceStatus.text.toLowerCase() == "done" ||
                      form.InvoiceStatus.text.toLowerCase() == "yes",
                  onChanged: (val) {
                    setState(() {
                      form.InvoiceStatus.text = val ? "Done" : "Pending";
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],

          if (form.canView("InvoicePrintedBy")) ...[
            IgnorePointer(
              ignoring: !form.canEdit("InvoicePrintedBy"),
              child: Opacity(
                opacity: form.canEdit("InvoicePrintedBy") ? 1 : 0.6,
                child: TextInput(
                  label: "Invoice Printed By",
                  hint: "Name",
                  controller: form.InvoicePrintedBy,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],

          // ===== ACCOUNT STATUS TOGGLE =====
          if (form.canView("AccountStatus")) ...[
            IgnorePointer(
              ignoring: !form.canEdit("AccountStatus"),
              child: Opacity(
                opacity: form.canEdit("AccountStatus") ? 1 : 0.6,
                child: FlexibleToggle(
                  label: "Account Status",
                  inactiveText: "Pending",
                  activeText: "Done",
                  initialValue: form.AccountStatus.text.toLowerCase() == "done",
                  onChanged: (val) {
                    setState(() {
                      form.AccountStatus.text = val ? "Done" : "Pending";
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],

          if (form.canView("ParticularSlider")) ...[
            const Text(
              "Particular",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            IgnorePointer(
              ignoring: !form.canEdit("ParticularSlider"),
              child: Opacity(
                opacity: form.canEdit("ParticularSlider") ? 1 : 0.6,
                child: FlexibleSlider(
                  max: 10,
                  onChanged: (v) {
                    form.ParticularSlider.text = v.toString();
                  },
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],

          // ===== SUBMIT & SAVE BUTTON =====



          const SizedBox(height: 40),
        ],
      ),
    );
  }
}