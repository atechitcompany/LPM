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

  List<String> _bladeItems = ["No"];
  List<String> _creasingItems = ["No"];
  List<String> _capsuleItems = ["No"];
  bool _loadingBlades = true;
  bool _loadingCreasings = true;
  bool _loadingCapsules = true;

  @override
  void initState() {
    super.initState();
    _fetchBlades();
    _fetchCreasings();
    _fetchCapsules();
  }

  Future<void> _fetchBlades() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection("Blades")
          .get();

      final items = snap.docs
          .map((doc) => (doc.data()['Blades'] ?? '').toString())
          .where((val) => val.isNotEmpty)
          .toList();

      setState(() {
        _bladeItems = ["No", ...items];
        _loadingBlades = false;
      });
    } catch (e) {
      debugPrint("❌ Error fetching Blades: $e");
      setState(() => _loadingBlades = false);
    }
  }

  Future<void> _fetchCreasings() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection("Creasings")
          .get();

      final items = snap.docs
          .map((doc) => (doc.data()['Creasings'] ?? '').toString())
          .where((val) => val.isNotEmpty)
          .toList();

      setState(() {
        _creasingItems = ["No", ...items];
        _loadingCreasings = false;
      });
    } catch (e) {
      debugPrint("❌ Error fetching Creasings: $e");
      setState(() => _loadingCreasings = false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    if (NewFormScope.of(context).mode == "edit") {
      _loadDesignerData();
    }
  }

  Future<void> _fetchCapsules() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection("Capsules")
          .get();

      final items = snap.docs
          .map((doc) => (doc.data()['Capsules'] ?? '').toString())
          .where((val) => val.isNotEmpty)
          .toList();

      setState(() {
        _capsuleItems = ["No", ...items];
        _loadingCapsules = false;
      });
    } catch (e) {
      debugPrint("❌ Error fetching Capsules: $e");
      setState(() => _loadingCapsules = false);
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
              _loadingBlades
                  ? const Center(child: CircularProgressIndicator())
                  : SearchableDropdownWithInitial(
                label: "Blade",
                items: _bladeItems,
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
              _loadingCreasings
                  ? const Center(child: CircularProgressIndicator())
                  : SearchableDropdownWithInitial(
                label: "Creasing",
                items: _creasingItems,
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
              _loadingCapsules
                  ? const Center(child: CircularProgressIndicator())
                  : AddableSearchDropdown(
                label: "Capsule",
                items: _capsuleItems,
                initialValue: form.CapsuleType.text.isEmpty ? "No" : form.CapsuleType.text,
                firestoreCollection: "Capsules",  // ✅ NEW
                firestoreField: "Capsules",       // ✅ NEW
                onChanged: (v) {
                  form.CapsuleType.text = v ?? "";
                },
                onAdd: (newItem) {
                  setState(() {
                    _capsuleItems.add(newItem);
                  });
                },
              ),
              const SizedBox(height: 26),
            ],
          ],
        ),
      ),
    );
  }
}