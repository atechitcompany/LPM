import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lightatech/Production/JobCreation/screens/forms/new_form.dart';
import 'package:lightatech/FormComponents/SearchableDropdownWithInitial.dart';
import 'package:lightatech/FormComponents/TextInput.dart';
import 'package:lightatech/FormComponents/AddableSearchDropdown.dart';
import 'package:lightatech/FormComponents/GSTSelector.dart';
import 'package:lightatech/FormComponents/AutoIncrementField.dart';
import 'package:lightatech/FormComponents/PrioritySelector.dart';
import 'package:lightatech/FormComponents/FlexibleToggle.dart';
import 'package:lightatech/FormComponents/FileUploadBox.dart';
import 'package:lightatech/FormComponents/FlexibleSlider.dart';
import 'package:lightatech/FormComponents/NumberStepper.dart';
import 'package:lightatech/FormComponents/AutoCalcTextbox.dart';

import '../new_form_scope.dart';


class DeliveryPage extends StatefulWidget {
  const DeliveryPage({super.key});

  @override
  State<DeliveryPage> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {
  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Delivery")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SearchableDropdownWithInitial(
              label: "Party Name *",
              items: form.parties,
              onChanged: (v) {},
            ),

            const SizedBox(height: 30),

            SearchableDropdownWithInitial(
              label: "Designer Created By",
              items: form.parties,
              onChanged: (v) {
                form.DesignerCreatedBy.text = v ?? "";
              },
            ),

            const SizedBox(height: 30),

            SearchableDropdownWithInitial(
              label: "Auto Bending Created By",
              items: form.parties,
              onChanged: (v) {},
            ),

            const SizedBox(height: 30),

            SearchableDropdownWithInitial(
              label: "Laser Cutting Created By",
              items: form.parties,
              onChanged: (v) {},
            ),

            const SizedBox(height: 30),

            SearchableDropdownWithInitial(
              label: "Accounts Created By",
              items: form.parties,
              onChanged: (v) {},
            ),

          ],
        ),
      ),
    );
  }
}
