import 'package:flutter/material.dart';
import '../new_form_scope.dart';
import 'package:lightatech/FormComponents/AddableSearchDropdown.dart';
import 'package:lightatech/FormComponents/NumberStepper.dart';

class DesignerPage5 extends StatelessWidget {
  const DesignerPage5({super.key});

  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Designer 5"),
        backgroundColor: Colors.yellow,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ✅ Male Emboss
            if (form.canView("MaleEmbossType")) ...[
              AddableSearchDropdown(
                label: "Male Emboss",
                items: form.jobs,
                initialValue: "No",
                onAdd: (newJob) => form.jobs.add(newJob),
                onChanged: (v) {
                  form.MaleEmbossType.text = v ?? "";
                },
              ),
              const SizedBox(height: 30),
            ],

            /// ✅ X
            if (form.canView("X")) ...[
              const Text(
                "X",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              NumberStepper(
                step: 0.01,
                controller: form.X,
                onChanged: (val) {
                  form.X.text = val.toString();
                  form.calculateXY();
                },
              ),
              const SizedBox(height: 30),
            ],

            /// ✅ Y
            if (form.canView("Y")) ...[
              const Text(
                "Y",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              NumberStepper(
                step: 0.01,
                controller: form.Y,
                onChanged: (val) {
                  form.Y.text = val.toString();
                  form.calculateXY();
                },
              ),
              const SizedBox(height: 30),
            ],

            /// ✅ Female Emboss
            if (form.canView("FemaleEmbossType")) ...[
              AddableSearchDropdown(
                label: "Female Emboss",
                items: form.jobs,
                initialValue: "No",
                onAdd: (newJob) => form.jobs.add(newJob),
                onChanged: (v) {
                  form.FemaleEmbossType.text = v ?? "";
                },
              ),
              const SizedBox(height: 30),
            ],

            /// ✅ X2
            if (form.canView("X2")) ...[
              const Text(
                "X2",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              NumberStepper(
                step: 0.01,
                controller: form.X2,
                onChanged: (val) {
                  form.X2.text = val.toString();
                  form.calculateXY2();
                },
              ),
              const SizedBox(height: 30),
            ],

            /// ✅ Y2
            if (form.canView("Y2")) ...[
              const Text(
                "Y2",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              NumberStepper(
                step: 0.01,
                controller: form.Y2,
                onChanged: (val) {
                  form.Y2.text = val.toString();
                  form.calculateXY2();
                },
              ),
              const SizedBox(height: 30),
            ],
          ],
        ),
      ),
    );
  }
}
