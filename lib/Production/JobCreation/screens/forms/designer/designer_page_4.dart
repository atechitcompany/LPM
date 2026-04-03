import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  List<String> _perforationItems = ["No"];
  List<String> _zigZagBladeItems = ["No"];
  List<String> _rubberItems = ["No"];
  List<String> _holeItems = ["No"];
  bool _loadingPerforations = true;
  bool _loadingZigZagBlades = true;
  bool _loadingRubbers = true;
  bool _loadingHoles = true;

  @override
  void initState() {
    super.initState();
    _fetchPerforations();
    _fetchZigZagBlades();
    _fetchRubbers();
    _fetchHoles();
  }

  Future<void> _fetchPerforations() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection("Perforations")
          .get();

      final items = snap.docs
          .map((doc) => (doc.data()['Perforations'] ?? '').toString())
          .where((val) => val.isNotEmpty)
          .toList();

      setState(() {
        _perforationItems = ["No", ...items];
        _loadingPerforations = false;
      });
    } catch (e) {
      debugPrint("❌ Error fetching Perforations: $e");
      setState(() => _loadingPerforations = false);
    }
  }

  Future<void> _fetchZigZagBlades() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection("Zig Zags Blades")
          .get();

      final items = snap.docs
          .map((doc) => (doc.data()['Zig Zags Blades'] ?? '').toString())
          .where((val) => val.isNotEmpty)
          .toList();

      setState(() {
        _zigZagBladeItems = ["No", ...items];
        _loadingZigZagBlades = false;
      });
    } catch (e) {
      debugPrint("❌ Error fetching Zig Zag Blades: $e");
      setState(() => _loadingZigZagBlades = false);
    }
  }

  Future<void> _fetchRubbers() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection("Rubbers")
          .get();

      final items = snap.docs
          .map((doc) => (doc.data()['Rubbers'] ?? '').toString())
          .where((val) => val.isNotEmpty)
          .toList();

      setState(() {
        _rubberItems = ["No", ...items];
        _loadingRubbers = false;
      });
    } catch (e) {
      debugPrint("❌ Error fetching Rubbers: $e");
      setState(() => _loadingRubbers = false);
    }
  }

  Future<void> _fetchHoles() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection("Holes")
          .get();

      final items = snap.docs
          .map((doc) => (doc.data()['Holes'] ?? '').toString())
          .where((val) => val.isNotEmpty)
          .toList();

      setState(() {
        _holeItems = ["No", ...items];
        _loadingHoles = false;
      });
    } catch (e) {
      debugPrint("❌ Error fetching Holes: $e");
      setState(() => _loadingHoles = false);
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

  Future<void> _loadDesignerData() async {
    final form = NewFormScope.of(context);
    final uri = GoRouterState.of(context).uri;
    final dataJson = uri.queryParameters['data'];
    final lpmParam = uri.queryParameters['lpm'];

    if (dataJson != null && dataJson.isNotEmpty) {
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

        debugPrint("✅ DesignerPage4 loaded data from Firestore");
      } catch (e) {
        debugPrint("❌ Error fetching from Firestore: $e");
      }
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
              _loadingPerforations
                  ? const Center(child: CircularProgressIndicator())
                  : AddableSearchDropdown(
                label: "Perforation",
                items: _perforationItems,
                initialValue: form.Perforation.text.isEmpty ? "No" : form.Perforation.text,
                firestoreCollection: "Perforations",
                firestoreField: "Perforations",
                onChanged: (v) {
                  setState(() {
                    form.Perforation.text = (v ?? "No").trim();
                  });

                  if (form.Perforation.text.toLowerCase() == "no") {
                    form.PerforationSelectedBy.clear();
                  } else {
                    form.PerforationSelectedBy.text = selectedByText(context);
                  }
                },
                onAdd: (newItem) {
                  setState(() {
                    _perforationItems.add(newItem);
                  });
                },
              ),
            ],

            /// ✅ Perforation Selected By
            if (isPerforationSelected && form.canView("PerforationSelectedBy")) ...[
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
              _loadingZigZagBlades
                  ? const Center(child: CircularProgressIndicator())
                  : AddableSearchDropdown(
                label: "Zig Zag Blade",
                items: _zigZagBladeItems,
                initialValue: form.ZigZagBlade.text.isEmpty ? "No" : form.ZigZagBlade.text,
                firestoreCollection: "Zig Zags Blades",
                firestoreField: "Zig Zags Blades",
                onChanged: (v) {
                  setState(() {
                    form.ZigZagBlade.text = (v ?? "No").trim();
                  });

                  if (form.ZigZagBlade.text.toLowerCase() == "no") {
                    form.ZigZagBladeSelectedBy.clear();
                  } else {
                    form.ZigZagBladeSelectedBy.text = selectedByText(context);
                  }
                },
                onAdd: (newItem) {
                  setState(() {
                    _zigZagBladeItems.add(newItem);
                  });
                },
              ),
            ],

            /// ✅ Zig Zag Blade Selected By
            if (isZigZagBladeSelected && form.canView("ZigZagBladeSelectedBy")) ...[
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
              _loadingRubbers
                  ? const Center(child: CircularProgressIndicator())
                  : AddableSearchDropdown(
                label: "Rubber",
                items: _rubberItems,
                initialValue: form.RubberType.text.isEmpty ? "No" : form.RubberType.text,
                firestoreCollection: "Rubbers",
                firestoreField: "Rubbers",
                onChanged: (v) {
                  setState(() {
                    form.RubberType.text = (v ?? "No").trim();
                  });

                  if (form.RubberType.text.toLowerCase() == "no") {
                    form.RubberSelectedBy.clear();
                  } else {
                    form.RubberSelectedBy.text = selectedByText(context);
                  }
                },
                onAdd: (newItem) {
                  setState(() {
                    _rubberItems.add(newItem);
                  });
                },
              ),
            ],

            /// ✅ Rubber Selected By
            if (isRubberSelected && form.canView("RubberSelectedBy")) ...[
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
              _loadingHoles
                  ? const Center(child: CircularProgressIndicator())
                  : AddableSearchDropdown(
                label: "Hole",
                items: _holeItems,
                initialValue: form.HoleType.text.isEmpty ? "No" : form.HoleType.text,
                firestoreCollection: "Holes",
                firestoreField: "Holes",
                onChanged: (v) {
                  setState(() {
                    form.HoleType.text = (v ?? "No").trim();
                  });

                  if (form.HoleType.text.toLowerCase() == "no") {
                    form.HoleSelectedBy.clear();
                  } else {
                    form.HoleSelectedBy.text = selectedByText(context);
                  }
                },
                onAdd: (newItem) {
                  setState(() {
                    _holeItems.add(newItem);
                  });
                },
              ),
            ],

            /// ✅ Hole Selected By
            if (isHoleSelected && form.canView("HoleSelectedBy")) ...[
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