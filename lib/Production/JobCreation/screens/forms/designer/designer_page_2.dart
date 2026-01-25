import 'package:flutter/material.dart';
import '../new_form_scope.dart';
import 'package:lightatech/FormComponents/PrioritySelector.dart';
import 'package:lightatech/FormComponents/TextInput.dart';
import 'package:lightatech/FormComponents/FlexibleToggle.dart';
import 'package:lightatech/FormComponents/FileUploadBox.dart';
import 'package:lightatech/FormComponents/AddableSearchDropdown.dart';

class DesignerPage2 extends StatefulWidget {
  const DesignerPage2({super.key});

  @override
  State<DesignerPage2> createState() => _DesignerPage2State();
}

class _DesignerPage2State extends State<DesignerPage2> {
  bool isDesigningDone = false;

  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);
    final bool isPlySelected =
        form.PlyType.text.trim().toLowerCase() != "no";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Designer 2"),
        backgroundColor: Colors.yellow,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ✅ Priority
            if (form.canView("Priority")) ...[
              const Text(
                "Priority",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              PrioritySelector(
                onChanged: (v) {
                  form.Priority.text = v ?? "";
                },
              ),
              const SizedBox(height: 30),
            ],

            /// ✅ Remark
            if (form.canView("Remark")) ...[
              TextInput(
                label: "Remark",
                hint: "Remark",
                controller: form.Remark,
                initialValue: "NO REMARK",
              ),
              const SizedBox(height: 30),
            ],

            /// ✅ Designing Toggle
            if (form.canView("DesigningStatus")) ...[
              FlexibleToggle(
                label: "Designing *",
                inactiveText: "Pending",
                activeText: "Done",
                initialValue: isDesigningDone,
                onChanged: (val) {
                  setState(() {
                    isDesigningDone = val;
                  });

                  form.DesigningStatus.text =
                  val ? "Done" : "Pending";

                  if (!val) {
                    form.DesignedBy.clear();
                  }
                },
              ),
              const SizedBox(height: 30),
            ],

            /// ✅ Drawing Attachment
            if (form.canView("DrawingAttachment")) ...[
              const Text(
                "Drawing Attachment",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              FileUploadBox(
                onFileSelected: (file) {
                  debugPrint("Drawing: ${file.name}");
                },
              ),
              const SizedBox(height: 30),
            ],

            /// ✅ Rubber Report (only when designing done)
            if (isDesigningDone && form.canView("RubberReport")) ...[
              const Text(
                "Rubber Report",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              FileUploadBox(
                onFileSelected: (file) {
                  debugPrint("Rubber Report: ${file.name}");
                },
              ),
              const SizedBox(height: 30),
            ],

            /// ✅ Punch Report
            if (form.canView("PunchReport")) ...[
              const Text(
                "Punch Report",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              FileUploadBox(
                onFileSelected: (file) {
                  debugPrint("Punch Report: ${file.name}");
                },
              ),
              const SizedBox(height: 30),
            ],

            /// ✅ Ply
            if (form.canView("PlyType")) ...[
              AddableSearchDropdown(
                label: "Ply",
                items: form.ply,
                initialValue: "No",
                onChanged: (v) {
                  setState(() {
                    form.PlyType.text = v ?? "";
                  });

                  final selected = (v ?? "").trim().toLowerCase();
                  if (selected == "no") {
                    form.PlySelectedBy.clear();
                    return;
                  }

                  form.PlySelectedBy.text =
                  "Company on ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} "
                      "at ${TimeOfDay.now().format(context)}";
                },
                onAdd: (v) => form.ply.add(v),
              ),
            ],

            /// ✅ Ply Selected By (auto-filled, view-only logically)
            if (isPlySelected && form.canView("PlySelectedBy")) ...[
              const SizedBox(height: 30),
              const Text(
                "Ply Selected By",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: form.PlySelectedBy,
                enabled: false,
                decoration: InputDecoration(
                  hintText: "Will be filled automatically",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
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
