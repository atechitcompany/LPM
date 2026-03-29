import 'package:flutter/material.dart';
import 'package:lightatech/FormComponents/NumberStepper.dart';
import 'package:lightatech/FormComponents/AutoCalcTextbox.dart';
import '../../new_form_scope.dart';

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

          // ===== CONTROLLED EDIT FIELDS =====

          if (form.canView("CapsuleRate")) ...[
            const Text("Capsule Rate",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            IgnorePointer(
              ignoring: !form.canEdit("CapsuleRate"),
              child: Opacity(
                opacity: form.canEdit("CapsuleRate") ? 1 : 0.6,
                child: NumberStepper(
                  step: 0.01,
                  initialValue: double.tryParse(form.CapsuleRate.text) ?? 0,
                  controller: form.CapsuleRate,
                  onChanged: (val) {
                    form.CapsuleRate.text = val.toString();
                    setState(() {});
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],

          if (form.canView("CapsulePcs")) ...[
            const Text("Capsule Pcs",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            IgnorePointer(
              ignoring: !form.canEdit("CapsulePcs"),
              child: Opacity(
                opacity: form.canEdit("CapsulePcs") ? 1 : 0.6,
                child: NumberStepper(
                  step: 1,
                  initialValue: double.tryParse(form.CapsulePcs.text) ?? 0,
                  controller: form.CapsulePcs,
                  onChanged: (val) {
                    form.CapsulePcs.text = val.toString();
                    setState(() {});
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],

          if (form.canView("CreasingSize")) ...[
            const Text("Creasing Size",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
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

          // ===== FREE UI (AUTOCALC) =====
          AutoCalcTextBox(label: "Creasing Amount", value: "0"),
          const SizedBox(height: 30),

          // ===== CONTROLLED EDIT FIELDS =====
          if (form.canView("PerforationSize")) ...[
            const Text("Perforation Size",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            IgnorePointer(
              ignoring: !form.canEdit("PerforationSize"),
              child: Opacity(
                opacity: form.canEdit("PerforationSize") ? 1 : 0.6,
                child: NumberStepper(
                  step: 1,
                  initialValue: double.tryParse(form.PerforationSize.text) ?? 0,
                  controller: form.PerforationSize,
                  onChanged: (val) {
                    form.PerforationSize.text = val.toString();
                    setState(() {});
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],

          AutoCalcTextBox(label: "Perforation Amount", value: "0"),
          const SizedBox(height: 30),

          if (form.canView("ZigZagBladeSize")) ...[
            const Text("Zig-Zag Blade Size",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            IgnorePointer(
              ignoring: !form.canEdit("ZigZagBladeSize"),
              child: Opacity(
                opacity: form.canEdit("ZigZagBladeSize") ? 1 : 0.6,
                child: NumberStepper(
                  step: 1,
                  initialValue: double.tryParse(form.ZigZagBladeSize.text) ?? 0,
                  controller: form.ZigZagBladeSize,
                  onChanged: (val) {
                    form.ZigZagBladeSize.text = val.toString();
                    setState(() {});
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],

          AutoCalcTextBox(label: "Zig Zag Blade Amount", value: "0"),
          const SizedBox(height: 30),

          if (form.canView("RubberSize")) ...[
            const Text("Rubber Size",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            IgnorePointer(
              ignoring: !form.canEdit("RubberSize"),
              child: Opacity(
                opacity: form.canEdit("RubberSize") ? 1 : 0.6,
                child: NumberStepper(
                  step: 1,
                  initialValue: double.tryParse(form.RubberSize.text) ?? 0,
                  controller: form.RubberSize,
                  onChanged: (val) {
                    form.RubberSize.text = val.toString();
                    setState(() {});
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],

          AutoCalcTextBox(label: "Rubber Amount", value: "0"),
          const SizedBox(height: 30),

          AutoCalcTextBox(label: "Hole Rate", value: "0"),
          const SizedBox(height: 30),

          if (form.canView("HoleType")) ...[
            const Text("Holes",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            IgnorePointer(
              ignoring: !form.canEdit("HoleType"),
              child: Opacity(
                opacity: form.canEdit("HoleType") ? 1 : 0.6,
                child: NumberStepper(
                  step: 1,
                  initialValue: double.tryParse(form.HoleType.text) ?? 0,
                  controller: form.HoleType,
                  onChanged: (val) {
                    form.HoleType.text = val.toString();
                    setState(() {});
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],

          AutoCalcTextBox(label: "Hole Amount", value: "0"),
          const SizedBox(height: 30),

          if (form.canView("CourierCharges")) ...[
            const Text("Courier Charges",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 10),
            IgnorePointer(
              ignoring: !form.canEdit("CourierCharges"),
              child: Opacity(
                opacity: form.canEdit("CourierCharges") ? 1 : 0.6,
                child: NumberStepper(
                  step: 0.01,
                  initialValue: double.tryParse(form.CourierCharges.text) ?? 0,
                  controller: form.CourierCharges,
                  onChanged: (val) {
                    form.CourierCharges.text = val.toString();
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