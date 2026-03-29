import 'package:flutter/material.dart';
import '../../new_form_scope.dart';
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

          // ===== DELIVERY CREATED BY =====

          if (form.canView("DeliveryCreatedBy"))
            IgnorePointer(
              ignoring: !form.canEdit("DeliveryCreatedBy"),
              child: Opacity(
                opacity: form.canEdit("DeliveryCreatedBy") ? 1 : 0.6,
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

          // ===== DELIVERY STATUS =====

          IgnorePointer(
            ignoring: !form.canEdit("DeliveryStatus"),
            child: Opacity(
              opacity: form.canEdit("DeliveryStatus") ? 1 : 0.6,
              child: FlexibleToggle(
                label: "Delivery",
                inactiveText: "Pending",
                activeText: "Done",
                initialValue:
                form.DeliveryStatus.text.toLowerCase() == "done",
                onChanged: (val) {
                  form.DeliveryStatus.text = val ? "Done" : "Pending";
                },
              ),
            ),
          ),

          const SizedBox(height: 30),

          // ===== DIE / PUNCH IMAGE =====

          if (form.canView("DiePunchImage")) ...[
            const Text(
              "Die/Punch Image",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),

            IgnorePointer(
              ignoring: !form.canEdit("DiePunchImage"),
              child: Opacity(
                opacity: form.canEdit("DiePunchImage") ? 1 : 0.6,
                child: FileUploadBox(
                  onFileSelected: (file) {
                    print("Selected File: ${file.name}");
                  },
                ),
              ),
            ),
          ],

          const SizedBox(height: 30),

          // ===== INVOICE IMAGE =====

          if (form.canView("InvoiceImage")) ...[
            const Text(
              "Invoice Image",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),

            IgnorePointer(
              ignoring: !form.canEdit("InvoiceImage"),
              child: Opacity(
                opacity: form.canEdit("InvoiceImage") ? 1 : 0.6,
                child: FileUploadBox(
                  onFileSelected: (file) {
                    print("Selected File: ${file.name}");
                  },
                ),
              ),
            ),
          ],

          const SizedBox(height: 30),

          // ===== DELIVERY URL =====

          if (form.canView("DeliveryURL"))
            IgnorePointer(
              ignoring: !form.canEdit("DeliveryURL"),
              child: Opacity(
                opacity: form.canEdit("DeliveryURL") ? 1 : 0.6,
                child: TextInput(
                  label: "Delivery URL",
                  hint: "",
                  controller: form.DeliveryURL,
                ),
              ),
            ),

          const SizedBox(height: 30),

          // ===== TRANSPORT NAME =====

          if (form.canView("TransportName"))
            IgnorePointer(
              ignoring: !form.canEdit("TransportName"),
              child: Opacity(
                opacity: form.canEdit("TransportName") ? 1 : 0.6,
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

        ],
      ),
    );
  }
}