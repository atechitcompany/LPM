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

    // ✅ Toggle initial states from controllers
    bool laserDone = form.LaserCuttingStatus.text.trim().toLowerCase() == "done";
    bool rubberFixingDone =
        form.RubberFixingDone.text.trim().toLowerCase() == "yes";
    bool whiteProfileRubber =
        form.WhiteProfileRubber.text.trim().toLowerCase() == "yes";

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
                setState(() {
                  form.StrippingType.text = (v ?? "No").trim();
                });
              },
              onAdd: (newJob) => form.jobs.add(newJob),
              initialValue: form.StrippingType.text.isEmpty
                  ? "No"
                  : form.StrippingType.text,
            ),

            const SizedBox(height: 30),

            FlexibleToggle(
              label: "Laser Cutting Status",
              inactiveText: "Pending",
              activeText: "Done",
              initialValue: laserDone,
              onChanged: (v) {
                setState(() {
                  form.LaserCuttingStatus.text = v ? "Done" : "Pending";
                });
              },
            ),

            const SizedBox(height: 30),

            FlexibleToggle(
              label: "Rubber Fixing Done",
              inactiveText: "No",
              activeText: "Yes",
              initialValue: rubberFixingDone,
              onChanged: (val) {
                setState(() {
                  form.RubberFixingDone.text = val ? "Yes" : "No";
                });
              },
            ),

            const SizedBox(height: 30),

            FlexibleToggle(
              label: "White Profile Rubber",
              inactiveText: "No",
              activeText: "Yes",
              initialValue: whiteProfileRubber,
              onChanged: (val) {
                setState(() {
                  form.WhiteProfileRubber.text = val ? "Yes" : "No";
                });
              },
            ),

            const SizedBox(height: 30),

            // ✅ Submit Button
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
                    await form.submitForm();
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
