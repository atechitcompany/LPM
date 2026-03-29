import 'package:flutter/material.dart';
import 'package:lightatech/FormComponents/SearchableDropdownWithInitial.dart';
import 'package:lightatech/FormComponents/FlexibleToggle.dart';
import 'package:lightatech/FormComponents/FileUploadBox.dart';
import 'package:lightatech/FormComponents/TextInput.dart';
import '../../new_form_scope.dart';

class AccountPage4Delivery extends StatefulWidget {
  const AccountPage4Delivery({super.key});

  @override
  State<AccountPage4Delivery> createState() => _AccountPage4DeliveryState();
}

class _AccountPage4DeliveryState extends State<AccountPage4Delivery> {
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
              child: SearchableDropdownWithInitial(
                label: "Delivery Created By",
                items: form.parties,
                initialValue: form.DeliveryCreatedBy.text.isEmpty
                    ? "Select"
                    : form.DeliveryCreatedBy.text,
                onChanged: (v) {
                  form.DeliveryCreatedBy.text = (v ?? "").trim();
                },
              ),
            ),
          ),

          const SizedBox(height: 30),

          IgnorePointer(
            ignoring: false,
            child: Opacity(
              opacity: 1,
              child: FlexibleToggle(
                label: "Delivery",
                inactiveText: "Pending",
                activeText: "Done",
                initialValue: form.DeliveryStatus.text.toLowerCase() == "done",
                onChanged: (val) {
                  setState(() {
                    form.DeliveryStatus.text = val ? "Done" : "Pending";
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 30),

          const Text(
            "Die/Punch Image",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),

          FileUploadBox(
            onFileSelected: (file) {
              debugPrint("Selected File: ${file.name}");
              debugPrint("Size: ${file.size}");
              debugPrint("Path: ${file.path}");
            },
          ),

          const SizedBox(height: 30),

          const Text(
            "Invoice Image",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),

          FileUploadBox(
            onFileSelected: (file) {
              debugPrint("Selected File: ${file.name}");
              debugPrint("Size: ${file.size}");
              debugPrint("Path: ${file.path}");
            },
          ),

          const SizedBox(height: 30),

          IgnorePointer(
            ignoring: false,
            child: Opacity(
              opacity: 1,
              child: TextInput(
                label: "Delivery URL",
                hint: "",
                controller: form.DeliveryURL,
              ),
            ),
          ),

          const SizedBox(height: 30),

          IgnorePointer(
            ignoring: false,
            child: Opacity(
              opacity: 1,
              child: SearchableDropdownWithInitial(
                label: "Transport Name",
                items: form.parties,
                initialValue: form.TransportName.text.isEmpty
                    ? "Select"
                    : form.TransportName.text,
                onChanged: (v) {
                  form.TransportName.text = (v ?? "").trim();
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