import 'package:flutter/material.dart';
import '../new_form_scope.dart';
import 'package:lightatech/FormComponents/AddableSearchDropdown.dart';
import 'package:lightatech/FormComponents/FlexibleToggle.dart';

class DesignerPage6 extends StatefulWidget {
  const DesignerPage6({super.key});

  @override
  State<DesignerPage6> createState() => _DesignerPage6State();
}

class _DesignerPage6State extends State<DesignerPage6> {
  bool isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Designer 6"),
        backgroundColor: Colors.yellow,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AddableSearchDropdown(
              label: "Stripping",
              items: form.jobs,
              onChanged: (v) {
                form.StrippingType.text = v ?? "";
              },
              onAdd: (newJob) => form.jobs.add(newJob),
              initialValue: "No",
            ),

            const SizedBox(height: 30),

            FlexibleToggle(
              label: "Laser Cutting Status",
              inactiveText: "Pending",
              activeText: "Done",
              onChanged: (v) {
                form.LaserCuttingStatus.text = v ? "Done" : "Pending";
              },
            ),

            const SizedBox(height: 30),

            FlexibleToggle(
              label: "Rubber Fixing Done",
              inactiveText: "No",
              activeText: "Yes",
              onChanged: (val) {
                form.RubberFixingDone.text = val ? "Yes" : "No";
              },
            ),

            const SizedBox(height: 30),

            FlexibleToggle(
              label: "White Profile Rubber",
              inactiveText: "No",
              activeText: "Yes",
              onChanged: (val) {
                form.WhiteProfileRubber.text = val ? "Yes" : "No";
              },
            ),

            const SizedBox(height: 30),

            // ✅ Submit Button (inside UI below rubber)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                  setState(() {
                    isSubmitting = true;
                  });

                  try {
                    // ✅ This submits ALL 6 pages data
                    await form.submitForm();

                    // ✅ Snackbar already handled inside form.submitForm()
                    // But just in case you want it here also, you can add again.
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Error submitting form"),
                      ),
                    );
                  } finally {
                    setState(() {
                      isSubmitting = false;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF8D94B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                ),
                child: isSubmitting
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text(
                  "Submit",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
