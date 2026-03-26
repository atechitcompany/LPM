import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../new_form_scope.dart';
import 'package:lightatech/FormComponents/AddableSearchDropdown.dart';
import 'package:lightatech/FormComponents/FlexibleToggle.dart';
import 'package:lightatech/FormComponents/TextInput.dart';
import 'dart:convert';

class DesignerPage4 extends StatefulWidget {
  const DesignerPage4({super.key});

  @override
  State<DesignerPage4> createState() => _DesignerPage4State();
}

class _DesignerPage4State extends State<DesignerPage4> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    if (NewFormScope.of(context).mode == "edit") {
      _loadDesignerData();
    }
  }

  Future<void> _loadDesignerData() async {
    final form = NewFormScope.of(context);
    final uri = GoRouterState.of(context).uri;
    final dataJson = uri.queryParameters['data'];

    if (dataJson == null || dataJson.isEmpty) {
      return;
    }

    try {
      final decodedData = jsonDecode(dataJson) as Map<String, dynamic>;

      setState(() {
        form.Perforation.text = decodedData["Perforation"] ?? "No";
        form.PerforationSelectedBy.text = decodedData["PerforationSelectedBy"] ?? "";
        form.ZigZagBlade.text = decodedData["ZigZagBlade"] ?? "No";
        form.ZigZagBladeSelectedBy.text = decodedData["ZigZagBladeSelectedBy"] ?? "";
        form.RubberType.text = decodedData["RubberType"] ?? "No";
        form.RubberSelectedBy.text = decodedData["RubberSelectedBy"] ?? "";
        form.HoleType.text = decodedData["HoleType"] ?? "No";
        form.HoleSelectedBy.text = decodedData["HoleSelectedBy"] ?? "";
        form.EmbossStatus.text = decodedData["EmbossStatus"] ?? "No";
        form.EmbossPcs.text = decodedData["EmbossPcs"] ?? "";
      });

      debugPrint("✅ DesignerPage4 loaded data from route");
    } catch (e) {
      debugPrint("❌ Error decoding data: $e");
    }
  }

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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
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
                initialValue: form.Perforation.text.isEmpty ? "No" : form.Perforation.text,
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
                items: form.bladeTypes,
                initialValue: form.ZigZagBlade.text.isEmpty ? "No" : form.ZigZagBlade.text,
                onAdd: (newJob) => form.bladeTypes.add(newJob),
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
                items: form.rubberTypes,
                initialValue: form.RubberType.text.isEmpty ? "No" : form.RubberType.text,
                onAdd: (newJob) => form.rubberTypes.add(newJob),
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
                items: form.holeTypes,
                initialValue: form.HoleType.text.isEmpty ? "No" : form.HoleType.text,
                onAdd: (newJob) => form.holeTypes.add(newJob),
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
                initialValue: form.EmbossStatus.text.toLowerCase() == "yes",
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
              ),
              const SizedBox(height: 26),
            ],
          ],
        ),
      ),
    );
  }
}