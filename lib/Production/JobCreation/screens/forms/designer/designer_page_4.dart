import 'package:flutter/material.dart';
import '../new_form_scope.dart';
import 'package:lightatech/FormComponents/AddableSearchDropdown.dart';
import 'package:lightatech/FormComponents/FlexibleToggle.dart';
import 'package:lightatech/FormComponents/TextInput.dart';

class DesignerPage4 extends StatefulWidget {
  const DesignerPage4({super.key});

  @override
  State<DesignerPage4> createState() => _DesignerPage4State();
}

class _DesignerPage4State extends State<DesignerPage4> {
  String selectedByText(BuildContext context) {
    return "Company on ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} "
        "at ${TimeOfDay.now().format(context)}";
  }

  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);

    final bool isPerforationSelected =
        form.Perforation.text.trim().toLowerCase() != "no";
    final bool isZigZagBladeSelected =
        form.ZigZagBlade.text.trim().toLowerCase() != "no";
    final bool isRubberSelected =
        form.RubberType.text.trim().toLowerCase() != "no";
    final bool isHoleSelected =
        form.HoleType.text.trim().toLowerCase() != "no";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Designer 4"),
        backgroundColor: Colors.yellow,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ✅ Perforation
            if (form.canView("Perforation")) ...[
              AddableSearchDropdown(
                label: "Perforation",
                items: form.jobs,
                initialValue: "No",
                onAdd: (newJob) => form.jobs.add(newJob),
                onChanged: (v) {
                  setState(() {
                    form.Perforation.text = v ?? "";
                  });

                  if ((v ?? "").trim().toLowerCase() == "no") {
                    form.PerforationSelectedBy.clear();
                  } else {
                    form.PerforationSelectedBy.text =
                        selectedByText(context);
                  }
                },
              ),
            ],

            /// ✅ Perforation Selected By
            if (isPerforationSelected &&
                form.canView("PerforationSelectedBy")) ...[
              const SizedBox(height: 20),
              const Text(
                "Perforation Done By",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: form.PerforationSelectedBy,
                enabled: false,
                decoration: InputDecoration(
                  hintText: "Will be filled automatically",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],

            if (form.canView("Perforation")) const SizedBox(height: 26),

            /// ✅ Zig Zag Blade
            if (form.canView("ZigZagBlade")) ...[
              AddableSearchDropdown(
                label: "Zig Zag Blade",
                items: form.jobs,
                initialValue: "No",
                onAdd: (newJob) => form.jobs.add(newJob),
                onChanged: (v) {
                  setState(() {
                    form.ZigZagBlade.text = v ?? "";
                  });

                  if ((v ?? "").trim().toLowerCase() == "no") {
                    form.ZigZagBladeSelectedBy.clear();
                  } else {
                    form.ZigZagBladeSelectedBy.text =
                        selectedByText(context);
                  }
                },
              ),
            ],

            /// ✅ Zig Zag Blade Selected By
            if (isZigZagBladeSelected &&
                form.canView("ZigZagBladeSelectedBy")) ...[
              const SizedBox(height: 20),
              const Text(
                "Zig Zag Blade Selected By",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: form.ZigZagBladeSelectedBy,
                enabled: false,
                decoration: InputDecoration(
                  hintText: "Will be filled automatically",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],

            if (form.canView("ZigZagBlade")) const SizedBox(height: 26),

            /// ✅ Rubber
            if (form.canView("RubberType")) ...[
              AddableSearchDropdown(
                label: "Rubber",
                items: form.jobs,
                initialValue: "No",
                onAdd: (newJob) => form.jobs.add(newJob),
                onChanged: (v) {
                  setState(() {
                    form.RubberType.text = v ?? "";
                  });

                  if ((v ?? "").trim().toLowerCase() == "no") {
                    form.RubberSelectedBy.clear();
                  } else {
                    form.RubberSelectedBy.text =
                        selectedByText(context);
                  }
                },
              ),
            ],

            /// ✅ Rubber Selected By
            if (isRubberSelected &&
                form.canView("RubberSelectedBy")) ...[
              const SizedBox(height: 20),
              const Text(
                "Rubber Selected By",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: form.RubberSelectedBy,
                enabled: false,
                decoration: InputDecoration(
                  hintText: "Will be filled automatically",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],

            if (form.canView("RubberType")) const SizedBox(height: 26),

            /// ✅ Hole
            if (form.canView("HoleType")) ...[
              AddableSearchDropdown(
                label: "Hole",
                items: form.jobs,
                initialValue: "No",
                onAdd: (newJob) => form.jobs.add(newJob),
                onChanged: (v) {
                  setState(() {
                    form.HoleType.text = v ?? "";
                  });

                  if ((v ?? "").trim().toLowerCase() == "no") {
                    form.HoleSelectedBy.clear();
                  } else {
                    form.HoleSelectedBy.text =
                        selectedByText(context);
                  }
                },
              ),
            ],

            /// ✅ Hole Selected By
            if (isHoleSelected &&
                form.canView("HoleSelectedBy")) ...[
              const SizedBox(height: 20),
              const Text(
                "Hole Selected By",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: form.HoleSelectedBy,
                enabled: false,
                decoration: InputDecoration(
                  hintText: "Will be filled automatically",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],

            if (form.canView("HoleType")) const SizedBox(height: 30),

            /// ✅ Emboss Toggle
            if (form.canView("EmbossStatus")) ...[
              FlexibleToggle(
                label: "Emboss",
                inactiveText: "No",
                activeText: "Yes",
                onChanged: (v) {
                  form.EmbossStatus.text = v ? "Yes" : "No";
                },
              ),
              const SizedBox(height: 26),
            ],

            /// ✅ Emboss Pcs
            if (form.canView("EmbossPcs")) ...[
              TextInput(
                label: "Emboss Pcs",
                hint: "No of Pcs",
                controller: form.EmbossPcs,
                initialValue: "No",
              ),
              const SizedBox(height: 26),
            ],
          ],
        ),
      ),
    );
  }
}
