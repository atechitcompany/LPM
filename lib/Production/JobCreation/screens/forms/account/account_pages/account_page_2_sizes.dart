import 'package:flutter/material.dart';
import 'package:lightatech/Production/JobCreation/screens/forms/new_form_scope.dart';
import 'package:lightatech/FormComponents/TextInput.dart';
import 'package:lightatech/FormComponents/FlexibleSlider.dart';
import 'package:lightatech/FormComponents/NumberStepper.dart';

class AccountPage2Sizes extends StatelessWidget {
  const AccountPage2Sizes({super.key});

  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Size 2
          TextInput(
            label: "Size2",
            hint: "name",
            controller: form.Size2,
            initialValue: "NO",
          ),

          const SizedBox(height: 30),

          // Size 3
          TextInput(
            label: "Size3",
            hint: "name",
            controller: form.Size3,
            initialValue: "NO",
          ),

          const SizedBox(height: 30),

          // Size 4
          TextInput(
            label: "Size4",
            hint: "name",
            controller: form.Size4,
            initialValue: "NO",
          ),

          const SizedBox(height: 30),

          // Size 5
          TextInput(
            label: "Size5",
            hint: "name",
            controller: form.Size5,
            initialValue: "NO",
          ),

          const SizedBox(height: 30),

          // Sizes Slider
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

          // Ups_32 Stepper
          const Text(
            "Ups_32",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),

          NumberStepper(
            step: 1,
            initialValue: 0,
            controller: form.Ups_32,
            onChanged: (val) {},
          ),

          const SizedBox(height: 30),

          // Extra Slider
          const Text(
            "Extra Slider",
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
