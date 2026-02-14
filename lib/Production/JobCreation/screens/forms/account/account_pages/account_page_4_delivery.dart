import 'package:flutter/material.dart';
import 'package:lightatech/Production/JobCreation/screens/forms/new_form_scope.dart';
import 'package:lightatech/FormComponents/SearchableDropdownWithInitial.dart';
import 'package:lightatech/FormComponents/FlexibleToggle.dart';
import 'package:lightatech/FormComponents/FileUploadBox.dart';
import 'package:lightatech/FormComponents/TextInput.dart';

class AccountPage4Delivery extends StatelessWidget {
  const AccountPage4Delivery({super.key});

  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // Delivery Created By (1)
          SearchableDropdownWithInitial(
            label: "Delivery Created By",
            items: form.parties,
            onChanged: (v) {},
          ),

          const SizedBox(height: 30),

          // Delivery Created By (2) — duplicated in original
          SearchableDropdownWithInitial(
            label: "Delivery Created By",
            items: form.parties,
            onChanged: (v) {},
          ),

          const SizedBox(height: 30),

          // Delivery Status
          FlexibleToggle(
            label: "Delivery",
            inactiveText: "Pending",
            activeText: "Done",
            initialValue: false,
            onChanged: (val) {
              form.DeliveryStatus.text = val ? "Yes" : "No";
            },
          ),

          const SizedBox(height: 30),

          // Die / Punch Image
          const Text(
            "Die/Punch Image",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),

          FileUploadBox(
            onFileSelected: (file) {
              // same logging as original
              print("Selected File: ${file.name}");
              print("Size: ${file.size}");
              print("Path: ${file.path}");
            },
          ),

          const SizedBox(height: 30),

          // Invoice Image
          const Text(
            "Invoice Image",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),

          FileUploadBox(
            onFileSelected: (file) {
              // same logging as original
              print("Selected File: ${file.name}");
              print("Size: ${file.size}");
              print("Path: ${file.path}");
            },
          ),

          const SizedBox(height: 30),

          // Delivery URL
          TextInput(
            label: "Delivery URL",
            hint: "",
            controller: form.DeliveryURL,
            initialValue: "Delivered",
          ),

          const SizedBox(height: 30),

          // Transport Name
          SearchableDropdownWithInitial(
            label: "Transport Name",
            items: form.parties,
            onChanged: (v) {},
          ),

        ],
      ),
    );
  }
}
