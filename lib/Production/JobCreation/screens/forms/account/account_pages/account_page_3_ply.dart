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

          // ===== CONTROLLED EDIT FIELDS =====

          if (form.canView("LaserPunchNew")) ...[
            IgnorePointer(
              ignoring: !form.canEdit("LaserPunchNew"),
              child: Opacity(
                opacity: form.canEdit("LaserPunchNew") ? 1 : 0.6,
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
          ],

          if (form.canView("PlyLength")) ...[
            const Text(
              "Ply Length",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),

            IgnorePointer(
              ignoring: !form.canEdit("PlyLength"),
              child: Opacity(
                opacity: form.canEdit("PlyLength") ? 1 : 0.6,
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
          ],

          if (form.canView("PlyBreadth")) ...[
            const Text(
              "Ply Breadth",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),

            IgnorePointer(
              ignoring: !form.canEdit("PlyBreadth"),
              child: Opacity(
                opacity: form.canEdit("PlyBreadth") ? 1 : 0.6,
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
          ],

          // ===== FREE UI (AUTOCALC BOXES) =====

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

          // ===== CONTROLLED EDIT FIELDS =====

          if (form.canView("BladeSize")) ...[
            const Text(
              "Blade Size",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),

            IgnorePointer(
              ignoring: !form.canEdit("BladeSize"),
              child: Opacity(
                opacity: form.canEdit("BladeSize") ? 1 : 0.6,
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
          ],

          // ===== FREE UI (AUTOCALC BOXES) =====

          AutoCalcTextBox(label: "Blade Amount", value: "0"),
          const SizedBox(height: 30),

          // ===== CONTROLLED EDIT FIELDS =====

          if (form.canView("CreasingSize")) ...[
            const Text(
              "Creasing Size",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),

            IgnorePointer(
              ignoring: !form.canEdit("CreasingSize"),
              child: Opacity(
                opacity: form.canEdit("CreasingSize") ? 1 : 0.6,
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
          ],

          // ===== FREE UI (AUTOCALC BOXES) =====

          AutoCalcTextBox(label: "Creasing Amount", value: "0"),
          const SizedBox(height: 30),

          // ===== CONTROLLED EDIT FIELDS =====

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
            const SizedBox(height: 40),
          ],

        ],
      ),
    );
  }
}