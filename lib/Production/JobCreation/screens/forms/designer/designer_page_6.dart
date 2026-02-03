import 'package:flutter/material.dart';
import '../new_form_scope.dart';
import 'package:lightatech/FormComponents/AddableSearchDropdown.dart';
import 'package:lightatech/FormComponents/FlexibleToggle.dart';
import 'package:go_router/go_router.dart';
import 'package:lightatech/routes/app_route_config.dart';
import 'package:lightatech/routes/app_route_constants.dart';

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

    final bool laserDone =
        form.LaserCuttingStatus.text.trim().toLowerCase() == "done";
    final bool rubberFixingDone =
        form.RubberFixingDone.text.trim().toLowerCase() == "yes";
    final bool whiteProfileRubber =
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

            /// ✅ Stripping
            if (form.canView("StrippingType")) ...[
              AddableSearchDropdown(
                label: "Stripping",
                items: form.jobs,
                initialValue: form.StrippingType.text.isEmpty
                    ? "No"
                    : form.StrippingType.text,
                onAdd: (newJob) => form.jobs.add(newJob),
                onChanged: (v) {
                  setState(() {
                    form.StrippingType.text = (v ?? "No").trim();
                  });
                },
              ),
              const SizedBox(height: 30),
            ],

            /// ✅ Laser Cutting Status
            if (form.canView("LaserCuttingStatus")) ...[
              FlexibleToggle(
                label: "Laser Cutting Status",
                inactiveText: "Pending",
                activeText: "Done",
                initialValue: laserDone,
                onChanged: (v) {
                  setState(() {
                    form.LaserCuttingStatus.text =
                    v ? "Done" : "Pending";
                  });
                },
              ),
              const SizedBox(height: 30),
            ],

            /// ✅ Rubber Fixing Done
            if (form.canView("RubberFixingDone")) ...[
              FlexibleToggle(
                label: "Rubber Fixing Done",
                inactiveText: "No",
                activeText: "Yes",
                initialValue: rubberFixingDone,
                onChanged: (val) {
                  setState(() {
                    form.RubberFixingDone.text =
                    val ? "Yes" : "No";
                  });
                },
              ),
              const SizedBox(height: 30),
            ],

            /// ✅ White Profile Rubber
            if (form.canView("WhiteProfileRubber")) ...[
              FlexibleToggle(
                label: "White Profile Rubber",
                inactiveText: "No",
                activeText: "Yes",
                initialValue: whiteProfileRubber,
                onChanged: (val) {
                  setState(() {
                    form.WhiteProfileRubber.text =
                    val ? "Yes" : "No";
                  });
                },
              ),
              const SizedBox(height: 30),
            ],

            /// ✅ Submit Button
            if (form.canView("submitButton")) ...[
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

                      context.go('/dashboard');
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                          Text("Error submitting form"),
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
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
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
          ],
        ),
      ),
    );
  }
}
