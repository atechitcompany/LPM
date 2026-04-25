import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../new_form_scope.dart';
import 'package:lightatech/FormComponents/SearchableDropdownWithInitial.dart';
import 'package:lightatech/FormComponents/PrioritySelector.dart';
import 'package:lightatech/FormComponents/TextInput.dart';
import 'package:lightatech/FormComponents/FlexibleToggle.dart';
import 'package:lightatech/FormComponents/FileUploadBox.dart';
import 'package:lightatech/FormComponents/AddableSearchDropdown.dart';
import 'dart:convert';

import 'designer_page_1.dart';
import 'designer_widgets.dart';

// Import shared widgets from page1
// import './designer_page_1.dart';

class DesignerPage2 extends StatefulWidget {
  const DesignerPage2({super.key});

  @override
  State<DesignerPage2> createState() => _DesignerPage2State();
}

class _DesignerPage2State extends State<DesignerPage2> {
  bool isDesigningDone = false;
  bool _initialized = false;

  List<String> _plyItems = [];
  bool _loadingPlys = true;
  List<String> _bladeItems = ["No"];
  List<String> _creasingItems = ["No"];
  List<String> _capsuleItems = ["No"];
  List<String> _perforationItems = ["No"];
  List<String> _zigZagBladeItems = ["No"];
  List<String> _rubberItems = ["No"];
  List<String> _holeItems = ["No"];
  List<String> _strippingItems = ["No"];

  bool _loadingBlades = true;
  bool _loadingCreasings = true;
  bool _loadingCapsules = true;
  bool _loadingPerforations = true;
  bool _loadingZigZagBlades = true;
  bool _loadingRubbers = true;
  bool _loadingHoles = true;
  bool _loadingStrippings = true;

  @override
  void initState() {
    super.initState();
    _fetchPlys();
    _fetchBlades();
    _fetchCreasings();
    _fetchCapsules();
    _fetchPerforations();
    _fetchZigZagBlades();
    _fetchRubbers();
    _fetchHoles();
    _fetchStrippings();
  }

  Future<void> _fetchPlys() async {
    try {
      final snap = await FirebaseFirestore.instance.collection("Plys").get();
      final items = snap.docs
          .map((doc) => (doc.data()['Plys'] ?? '').toString())
          .where((val) => val.isNotEmpty)
          .toList();
      setState(() {
        _plyItems = ["No", ...items];
        _loadingPlys = false;
      });
    } catch (e) {
      debugPrint("❌ Error fetching Plys: $e");
      setState(() => _loadingPlys = false);
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

  Future<void> _fetchBlades() async {
    try {
      final snap = await FirebaseFirestore.instance.collection("Blades").get();
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
      final snap = await FirebaseFirestore.instance.collection("Creasings").get();
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

  Future<void> _fetchCapsules() async {
    try {
      final snap = await FirebaseFirestore.instance.collection("Capsules").get();
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

  Future<void> _fetchPerforations() async {
    try {
      final snap = await FirebaseFirestore.instance.collection("Perforations").get();
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
      final snap = await FirebaseFirestore.instance.collection("Zig Zags Blades").get();
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
      final snap = await FirebaseFirestore.instance.collection("Rubbers").get();
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
      final snap = await FirebaseFirestore.instance.collection("Holes").get();
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

  Future<void> _fetchStrippings() async {
    try {
      final snap = await FirebaseFirestore.instance.collection("Strippings").get();
      final items = snap.docs
          .map((doc) => (doc.data()['Strippings'] ?? '').toString())
          .where((val) => val.isNotEmpty)
          .toList();
      setState(() {
        _strippingItems = ["No", ...items];
        _loadingStrippings = false;
      });
    } catch (e) {
      debugPrint("❌ Error fetching Strippings: $e");
      setState(() => _loadingStrippings = false);
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
          form.Priority.text = decodedData["Priority"] ?? "";
          form.Remark.text = decodedData["Remark"] ?? "NO REMARK";
          form.PlyType.text = decodedData["PlyType"] ?? "No";
          form.PlySelectedBy.text = decodedData["PlySelectedBy"] ?? "";
          form.Blade.text = decodedData["Blade"] ?? "No";
          form.BladeSelectedBy.text = decodedData["BladeSelectedBy"] ?? "";
          form.Creasing.text = decodedData["Creasing"] ?? "No";
          form.CreasingSelectedBy.text = decodedData["CreasingSelectedBy"] ?? "";
          form.Unknown.text = decodedData["Unknown"] ?? "";
          form.CapsuleType.text = decodedData["CapsuleType"] ?? "";
          form.Perforation.text = decodedData["Perforation"] ?? "No";
          form.PerforationSelectedBy.text = decodedData["PerforationSelectedBy"] ?? "";
          form.ZigZagBlade.text = decodedData["ZigZagBlade"] ?? "No";
          form.ZigZagBladeSelectedBy.text = decodedData["ZigZagBladeSelectedBy"] ?? "";
          form.RubberType.text = decodedData["RubberType"] ?? "No";
          form.RubberSelectedBy.text = decodedData["RubberSelectedBy"] ?? "";
          form.HoleType.text = decodedData["HoleType"] ?? "No";
          form.HoleSelectedBy.text = decodedData["HoleSelectedBy"] ?? "";
          form.StrippingType.text = decodedData["StrippingType"] ?? "No";
        });
        debugPrint("✅ DesignerPage2 loaded data from route");
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
          form.Priority.text = decodedData["Priority"] ?? "";
          form.Remark.text = decodedData["Remark"] ?? "NO REMARK";
          form.PlyType.text = decodedData["PlyType"] ?? "No";
          form.PlySelectedBy.text = decodedData["PlySelectedBy"] ?? "";
          form.Blade.text = decodedData["Blade"] ?? "No";
          form.BladeSelectedBy.text = decodedData["BladeSelectedBy"] ?? "";
          form.Creasing.text = decodedData["Creasing"] ?? "No";
          form.CreasingSelectedBy.text = decodedData["CreasingSelectedBy"] ?? "";
          form.Unknown.text = decodedData["Unknown"] ?? "";
          form.CapsuleType.text = decodedData["CapsuleType"] ?? "";
          form.Perforation.text = decodedData["Perforation"] ?? "No";
          form.PerforationSelectedBy.text = decodedData["PerforationSelectedBy"] ?? "";
          form.ZigZagBlade.text = decodedData["ZigZagBlade"] ?? "No";
          form.ZigZagBladeSelectedBy.text = decodedData["ZigZagBladeSelectedBy"] ?? "";
          form.RubberType.text = decodedData["RubberType"] ?? "No";
          form.RubberSelectedBy.text = decodedData["RubberSelectedBy"] ?? "";
          form.HoleType.text = decodedData["HoleType"] ?? "No";
          form.HoleSelectedBy.text = decodedData["HoleSelectedBy"] ?? "";
          form.StrippingType.text = decodedData["StrippingType"] ?? "No";
        });
        debugPrint("✅ DesignerPage2 loaded data from Firestore");
      } catch (e) {
        debugPrint("❌ Error fetching from Firestore: $e");
      }
    }
  }

  // ── helper ──────────────────────────────────────────────────────────────────
  String _selectedByText(BuildContext context) =>
      "Company on ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} "
          "at ${TimeOfDay.now().format(context)}";

  Widget _disabledField(TextEditingController controller, String label) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            enabled: false,
            decoration: InputDecoration(
              hintText: "Auto-filled",
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);

    final bool isBladeSelected = form.Blade.text.trim().toLowerCase() != "no";
    final bool isCreasingSelected = form.Creasing.text.trim().toLowerCase() != "no";
    final bool isPlySelected = form.PlyType.text.trim().toLowerCase() != "no";
    final bool isPerforationSelected = form.Perforation.text.trim().toLowerCase() != "no";
    final bool isZigZagBladeSelected = form.ZigZagBlade.text.trim().toLowerCase() != "no";
    final bool isRubberSelected = form.RubberType.text.trim().toLowerCase() != "no";
    final bool isHoleSelected = form.HoleType.text.trim().toLowerCase() != "no";

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 22),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text(
          "Add Designer Job",
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.black),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: DesignerStepHeader(currentStep: 2),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Ply ─────────────────────────────────────────────────────────
            if (form.canView("PlyType"))
              fieldCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionLabel("Ply"),
                    _loadingPlys
                        ? const Center(child: CircularProgressIndicator())
                        : AddableSearchDropdown(
                      label: "",
                      items: _plyItems,
                      initialValue: form.PlyType.text.isEmpty ? "No" : form.PlyType.text,
                      firestoreCollection: "Plys",
                      firestoreField: "Plys",
                      onChanged: (v) {
                        setState(() => form.PlyType.text = v ?? "");
                        final selected = (v ?? "").trim().toLowerCase();
                        if (selected == "no") {
                          form.PlySelectedBy.clear();
                          return;
                        }
                        form.PlySelectedBy.text =
                        "Company on ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year} "
                            "at ${TimeOfDay.now().format(context)}";
                      },
                      onAdd: (newItem) =>
                          setState(() => _plyItems.add(newItem)),
                    ),
                    if (isPlySelected && form.canView("PlySelectedBy"))
                      _disabledField(form.PlySelectedBy, "Ply Selected By"),
                  ],
                ),
              ),

            // ── Blade ────────────────────────────────────────────────────────
            if (form.canView("Blade"))
              fieldCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionLabel("Blade"),
                    _loadingBlades
                        ? const Center(child: CircularProgressIndicator())
                        : SearchableDropdownWithInitial(
                      label: "",
                      items: _bladeItems,
                      initialValue:
                      form.Blade.text.isEmpty ? "No" : form.Blade.text,
                      onChanged: (v) {
                        setState(() => form.Blade.text = (v ?? "No").trim());
                        if (form.Blade.text.toLowerCase() == "no") {
                          form.BladeSelectedBy.clear();
                        } else {
                          form.BladeSelectedBy.text = _selectedByText(context);
                        }
                      },
                    ),
                    if (isBladeSelected && form.canView("BladeSelectedBy"))
                      _disabledField(form.BladeSelectedBy, "Blade Selected By"),
                  ],
                ),
              ),

            // ── Creasing ─────────────────────────────────────────────────────
            if (form.canView("Creasing"))
              fieldCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionLabel("Creasing"),
                    _loadingCreasings
                        ? const Center(child: CircularProgressIndicator())
                        : SearchableDropdownWithInitial(
                      label: "",
                      items: _creasingItems,
                      initialValue: form.Creasing.text.isEmpty
                          ? "No"
                          : form.Creasing.text,
                      onChanged: (v) {
                        setState(
                                () => form.Creasing.text = (v ?? "No").trim());
                        if (form.Creasing.text.toLowerCase() == "no") {
                          form.CreasingSelectedBy.clear();
                        } else {
                          form.CreasingSelectedBy.text =
                              _selectedByText(context);
                        }
                      },
                    ),
                    if (isCreasingSelected && form.canView("CreasingSelectedBy"))
                      _disabledField(
                          form.CreasingSelectedBy, "Creasing Selected By"),
                  ],
                ),
              ),

            // ── Perforation ──────────────────────────────────────────────────
            if (form.canView("Perforation"))
              fieldCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionLabel("Perforation"),
                    _loadingPerforations
                        ? const Center(child: CircularProgressIndicator())
                        : AddableSearchDropdown(
                      label: "",
                      items: _perforationItems,
                      initialValue: form.Perforation.text.isEmpty
                          ? "No"
                          : form.Perforation.text,
                      firestoreCollection: "Perforations",
                      firestoreField: "Perforations",
                      onChanged: (v) {
                        setState(() =>
                        form.Perforation.text = (v ?? "No").trim());
                        if (form.Perforation.text.toLowerCase() == "no") {
                          form.PerforationSelectedBy.clear();
                        } else {
                          form.PerforationSelectedBy.text =
                              _selectedByText(context);
                        }
                      },
                      onAdd: (newItem) =>
                          setState(() => _perforationItems.add(newItem)),
                    ),
                    if (isPerforationSelected &&
                        form.canView("PerforationSelectedBy"))
                      _disabledField(
                          form.PerforationSelectedBy, "Perforation Done By"),
                  ],
                ),
              ),

            // ── Zig Zag Blade ────────────────────────────────────────────────
            if (form.canView("ZigZagBlade"))
              fieldCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionLabel("Zig Zag Blade"),
                    _loadingZigZagBlades
                        ? const Center(child: CircularProgressIndicator())
                        : AddableSearchDropdown(
                      label: "",
                      items: _zigZagBladeItems,
                      initialValue: form.ZigZagBlade.text.isEmpty
                          ? "No"
                          : form.ZigZagBlade.text,
                      firestoreCollection: "Zig Zags Blades",
                      firestoreField: "Zig Zags Blades",
                      onChanged: (v) {
                        setState(() =>
                        form.ZigZagBlade.text = (v ?? "No").trim());
                        if (form.ZigZagBlade.text.toLowerCase() == "no") {
                          form.ZigZagBladeSelectedBy.clear();
                        } else {
                          form.ZigZagBladeSelectedBy.text =
                              _selectedByText(context);
                        }
                      },
                      onAdd: (newItem) =>
                          setState(() => _zigZagBladeItems.add(newItem)),
                    ),
                    if (isZigZagBladeSelected &&
                        form.canView("ZigZagBladeSelectedBy"))
                      _disabledField(form.ZigZagBladeSelectedBy,
                          "Zig Zag Blade Selected By"),
                  ],
                ),
              ),

            // ── Rubber ───────────────────────────────────────────────────────
            if (form.canView("RubberType"))
              fieldCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionLabel("Rubber"),
                    _loadingRubbers
                        ? const Center(child: CircularProgressIndicator())
                        : AddableSearchDropdown(
                      label: "",
                      items: _rubberItems,
                      initialValue: form.RubberType.text.isEmpty
                          ? "No"
                          : form.RubberType.text,
                      firestoreCollection: "Rubbers",
                      firestoreField: "Rubbers",
                      onChanged: (v) {
                        setState(() =>
                        form.RubberType.text = (v ?? "No").trim());
                        if (form.RubberType.text.toLowerCase() == "no") {
                          form.RubberSelectedBy.clear();
                        } else {
                          form.RubberSelectedBy.text =
                              _selectedByText(context);
                        }
                      },
                      onAdd: (newItem) =>
                          setState(() => _rubberItems.add(newItem)),
                    ),
                    if (isRubberSelected && form.canView("RubberSelectedBy"))
                      _disabledField(
                          form.RubberSelectedBy, "Rubber Selected By"),
                  ],
                ),
              ),

            // ── Hole ─────────────────────────────────────────────────────────
            if (form.canView("HoleType"))
              fieldCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionLabel("Hole"),
                    _loadingHoles
                        ? const Center(child: CircularProgressIndicator())
                        : AddableSearchDropdown(
                      label: "",
                      items: _holeItems,
                      initialValue: form.HoleType.text.isEmpty
                          ? "No"
                          : form.HoleType.text,
                      firestoreCollection: "Holes",
                      firestoreField: "Holes",
                      onChanged: (v) {
                        setState(
                                () => form.HoleType.text = (v ?? "No").trim());
                        if (form.HoleType.text.toLowerCase() == "no") {
                          form.HoleSelectedBy.clear();
                        } else {
                          form.HoleSelectedBy.text =
                              _selectedByText(context);
                        }
                      },
                      onAdd: (newItem) =>
                          setState(() => _holeItems.add(newItem)),
                    ),
                    if (isHoleSelected && form.canView("HoleSelectedBy"))
                      _disabledField(form.HoleSelectedBy, "Hole Selected By"),
                  ],
                ),
              ),

            // ── Stripping ────────────────────────────────────────────────────
            if (form.canView("StrippingType"))
              fieldCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionLabel("Stripping"),
                    _loadingStrippings
                        ? const Center(child: CircularProgressIndicator())
                        : AddableSearchDropdown(
                      label: "",
                      items: _strippingItems,
                      initialValue: form.StrippingType.text.isEmpty
                          ? "No"
                          : form.StrippingType.text,
                      firestoreCollection: "Strippings",
                      firestoreField: "Strippings",
                      onChanged: (v) => setState(
                              () => form.StrippingType.text = (v ?? "No").trim()),
                      onAdd: (newItem) =>
                          setState(() => _strippingItems.add(newItem)),
                    ),
                  ],
                ),
              ),

            // ── Capsule ──────────────────────────────────────────────────────
            if (form.canView("CapsuleType"))
              fieldCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionLabel("Capsule"),
                    _loadingCapsules
                        ? const Center(child: CircularProgressIndicator())
                        : AddableSearchDropdown(
                      label: "",
                      items: _capsuleItems,
                      initialValue: form.CapsuleType.text.isEmpty
                          ? "No"
                          : form.CapsuleType.text,
                      firestoreCollection: "Capsules",
                      firestoreField: "Capsules",
                      onChanged: (v) => form.CapsuleType.text = v ?? "",
                      onAdd: (newItem) =>
                          setState(() => _capsuleItems.add(newItem)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),

    );
  }
}