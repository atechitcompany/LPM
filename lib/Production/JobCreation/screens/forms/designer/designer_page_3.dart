import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../new_form_scope.dart';
import 'package:lightatech/FormComponents/SearchableDropdownWithInitial.dart';
import 'package:lightatech/FormComponents/FlexibleToggle.dart';
import 'package:lightatech/FormComponents/TextInput.dart';
import 'package:lightatech/FormComponents/AddableSearchDropdown.dart';
import 'dart:convert';

class DesignerPage3 extends StatefulWidget {
  const DesignerPage3({super.key});

  @override
  State<DesignerPage3> createState() => _DesignerPage3State();
}

class _DesignerPage3State extends State<DesignerPage3> {
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
    final lpmParam = uri.queryParameters['lpm'];

    if (dataJson != null && dataJson.isNotEmpty) {
      try {
        final decodedData = jsonDecode(dataJson) as Map<String, dynamic>;

        setState(() {
          form.Blade.text = decodedData["Blade"] ?? "No";
          form.BladeSelectedBy.text = decodedData["BladeSelectedBy"] ?? "";
          form.Creasing.text = decodedData["Creasing"] ?? "No";
          form.CreasingSelectedBy.text = decodedData["CreasingSelectedBy"] ?? "";
          form.Unknown.text = decodedData["Unknown"] ?? "";
          form.CapsuleType.text = decodedData["CapsuleType"] ?? "";
        });

        debugPrint("✅ DesignerPage3 loaded data from route");
      } catch (e) {
        debugPrint("❌ Error decoding data: $e");
      }
    } else if (lpmParam != null && lpmParam.isNotEmpty) {
      debugPrint("⚠️ No data in route parameters, falling back to Firestore");
      try {
        final snap = await FirebaseFirestore.instance
            .collection("jobs")
            .doc(lpmParam)
            .get();

        if (!snap.exists) {
          debugPrint("❌ Firestore: document $lpmParam not found");
          return;
        }

        final decodedData =
            Map<String, dynamic>.from(snap.data()?["designer"]?["data"] ?? {});

        setState(() {
          form.Blade.text = decodedData["Blade"] ?? "No";
          form.BladeSelectedBy.text = decodedData["BladeSelectedBy"] ?? "";
          form.Creasing.text = decodedData["Creasing"] ?? "No";
          form.CreasingSelectedBy.text = decodedData["CreasingSelectedBy"] ?? "";
          form.Unknown.text = decodedData["Unknown"] ?? "";
          form.CapsuleType.text = decodedData["CapsuleType"] ?? "";
        });

        debugPrint("✅ DesignerPage3 loaded data from Firestore");
      } catch (e) {
        debugPrint("❌ Error fetching from Firestore: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);

    final bool isBladeSelected =
        form.Blade.text.trim().toLowerCase() != "no";
    final bool isCreasingSelected =
        form.Creasing.text.trim().toLowerCase() != "no";

    String selectedByText() {
      return "Company on ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} "
          "at ${TimeOfDay.now().format(context)}";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text("Designer 3"),
        backgroundColor: Colors.yellow,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ✅ Blade
            if (form.canView("Blade")) ...[
              SearchableDropdownWithInitial(
                label: "Blade",
                items: form.ply,
                initialValue:
                form.Blade.text.isEmpty ? "No" : form.Blade.text,
                onChanged: (v) {
                  setState(() {
                    form.Blade.text = (v ?? "No").trim();
                  });

                  if (form.Blade.text.toLowerCase() == "no") {
                    form.BladeSelectedBy.clear();
                  } else {
                    form.BladeSelectedBy.text = selectedByText();
                  }
                },
              ),
            ],

            /// ✅ Blade Selected By
            if (isBladeSelected && form.canView("BladeSelectedBy")) ...[
              const SizedBox(height: 20),
              const Text(
                "Blade Selected By",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: form.BladeSelectedBy,
                enabled: false,
                decoration: InputDecoration(
                  hintText: "Will be filled automatically",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],

            if (form.canView("Blade")) const SizedBox(height: 30),

            /// ✅ Creasing
            if (form.canView("Creasing")) ...[
              SearchableDropdownWithInitial(
                label: "Creasing",
                items: form.ply,
                initialValue:
                form.Creasing.text.isEmpty ? "No" : form.Creasing.text,
                onChanged: (v) {
                  setState(() {
                    form.Creasing.text = (v ?? "No").trim();
                  });

                  if (form.Creasing.text.toLowerCase() == "no") {
                    form.CreasingSelectedBy.clear();
                  } else {
                    form.CreasingSelectedBy.text = selectedByText();
                  }
                },
              ),
            ],

            /// ✅ Creasing Selected By
            if (isCreasingSelected && form.canView("CreasingSelectedBy")) ...[
              const SizedBox(height: 20),
              const Text(
                "Creasing Selected By",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: form.CreasingSelectedBy,
                enabled: false,
                decoration: InputDecoration(
                  hintText: "Will be filled automatically",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ],

            if (form.canView("Creasing")) const SizedBox(height: 30),

            /// ✅ Micro Serration – Half Cut
            if (form.canView("MicroSerrationHalfCut")) ...[
              FlexibleToggle(
                label: "Micro serration Half cut 23.60",
                inactiveText: "No",
                activeText: "Yes",
                initialValue: false,
                onChanged: (val) {},
              ),
              const SizedBox(height: 30),
            ],

            /// ✅ Micro Serration – Creasing
            if (form.canView("MicroSerrationCreasing")) ...[
              FlexibleToggle(
                label: "Micro serration Creasing 23.60",
                inactiveText: "No",
                activeText: "Yes",
                initialValue: false,
                onChanged: (val) {},
              ),
              const SizedBox(height: 30),
            ],

            /// ✅ Unknown
            if (form.canView("Unknown")) ...[
              TextInput(
                label: "Unknown",
                hint: "Unknown",
                controller: form.Unknown,
              ),
              const SizedBox(height: 26),
            ],

            /// ✅ Capsule
            if (form.canView("CapsuleType")) ...[
              AddableSearchDropdown(
                label: "Capsule",
                items: form.jobs,
                initialValue: form.CapsuleType.text.isEmpty ? "No" : form.CapsuleType.text,
                onChanged: (v) {
                  form.CapsuleType.text = v ?? "";
                },
                onAdd: (newJob) => form.jobs.add(newJob),
              ),
              const SizedBox(height: 26),
            ],
          ],
        ),
      ),
    );
  }
}