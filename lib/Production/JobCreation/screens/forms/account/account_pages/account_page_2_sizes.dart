import 'package:flutter/material.dart';
import 'package:lightatech/FormComponents/TextInput.dart';
import 'package:lightatech/FormComponents/FlexibleSlider.dart';
import 'package:lightatech/FormComponents/NumberStepper.dart';
import '../../new_form_scope.dart';

class AccountPage2Sizes extends StatefulWidget {
  const AccountPage2Sizes({super.key});

  @override
  State<AccountPage2Sizes> createState() => _AccountPage2SizesState();
}

class _AccountPage2SizesState extends State<AccountPage2Sizes> {
  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ===== EDIT FIELDS =====

          if (form.canView("Size2")) ...[
            IgnorePointer(
              ignoring: !form.canEdit("Size2"),
              child: Opacity(
                opacity: form.canEdit("Size2") ? 1 : 0.6,
                child: TextInput(
                  label: "Size2",
                  hint: "name",
                  controller: form.Size2,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],

          if (form.canView("Size3")) ...[
            IgnorePointer(
              ignoring: !form.canEdit("Size3"),
              child: Opacity(
                opacity: form.canEdit("Size3") ? 1 : 0.6,
                child: TextInput(
                  label: "Size3",
                  hint: "name",
                  controller: form.Size3,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],

          if (form.canView("Size4")) ...[
            IgnorePointer(
              ignoring: !form.canEdit("Size4"),
              child: Opacity(
                opacity: form.canEdit("Size4") ? 1 : 0.6,
                child: TextInput(
                  label: "Size4",
                  hint: "name",
                  controller: form.Size4,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],

          if (form.canView("Size5")) ...[
            IgnorePointer(
              ignoring: !form.canEdit("Size5"),
              child: Opacity(
                opacity: form.canEdit("Size5") ? 1 : 0.6,
                child: TextInput(
                  label: "Size5",
                  hint: "name",
                  controller: form.Size5,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],

          // ===== FREE UI (SLIDERS) =====

          const Text(
            "Sizes",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),

          FlexibleSlider(
            max: 10,
            onChanged: (v) {},
          ),

          const SizedBox(height: 30),

          // ===== CONTROLLED STEPPER =====

          if (form.canView("Ups_32")) ...[
            const Text(
              "Ups_32",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),

            IgnorePointer(
              ignoring: !form.canEdit("Ups_32"),
              child: Opacity(
                opacity: form.canEdit("Ups_32") ? 1 : 0.6,
                child: NumberStepper(
                  step: 1,
                  initialValue: double.tryParse(form.Ups_32.text) ?? 0,
                  controller: form.Ups_32,
                  onChanged: (val) {
                    form.Ups_32.text = val.toString();
                    setState(() {}); // Using setState as you had it
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],

          // ===== FREE UI (SLIDERS) =====

          const Text(
            "Extra Slider",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),

          FlexibleSlider(
            max: 10,
            onChanged: (v) {},
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}