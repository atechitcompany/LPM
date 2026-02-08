import 'package:flutter/material.dart';
import 'package:lightatech/Production/JobCreation/screens/forms/new_form_scope.dart';
import 'package:lightatech/FormComponents/SearchableDropdownWithInitial.dart';
import 'package:lightatech/FormComponents/TextInput.dart';
import 'package:lightatech/FormComponents/AddableSearchDropdown.dart';

class AccountPage1Basic extends StatelessWidget {
  const AccountPage1Basic({super.key});

  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Accounts Created By
          SearchableDropdownWithInitial(
            label: "Accounts Created By",
            items: form.parties,
            onChanged: (v) {},
          ),

          const SizedBox(height: 30),

          // Buyer's Order No
          TextInput(
            label: "Buyer's Order No",
            hint: "Order Number",
            controller: form.BuyerOrderNo,
          ),

          const SizedBox(height: 30),

          // Ups
          TextInput(
            label: "Ups",
            hint: "ups",
            controller: form.Ups,
            initialValue: "NO",
          ),

          const SizedBox(height: 30),

          // Size
          TextInput(
            label: "Size",
            hint: "name",
            controller: form.Size,
            initialValue: "NO",
          ),

          const SizedBox(height: 30),

          // Unknown
          TextInput(
            label: "Unknown",
            hint: "",
            controller: form.Unknown,
            initialValue: "NO",
          ),

          const SizedBox(height: 30),

          // Total Size
          TextInput(
            label: "Total Size",
            hint: "",
            controller: form.TotalSize,
            initialValue: "NO",
          ),

          const SizedBox(height: 30),

          // Delivery Address (Addable)
          AddableSearchDropdown(
            label: "Delivery Address",
            items: form.jobs,
            initialValue: form.ParticularJobName.text.isEmpty
                ? "No"
                : form.ParticularJobName.text,
            onChanged: (v) {
              form.ParticularJobName.text = (v ?? "").trim();
            },
            onAdd: (newJob) => form.jobs.add(newJob),
          ),

        ],
      ),
    );
  }
}
