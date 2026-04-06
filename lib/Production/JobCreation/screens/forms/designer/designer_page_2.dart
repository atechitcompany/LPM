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

class DesignerPage2 extends StatefulWidget {
  const DesignerPage2({super.key});

  @override
  State<DesignerPage2> createState() => _DesignerPage2State();
}

class _DesignerPage2State extends State<DesignerPage2> {
  bool isDesigningDone = false;
  bool _initialized = false;

  // ✅ NEW
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
      final snap = await FirebaseFirestore.instance
          .collection("Plys")
          .get();

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
  //EN-D2
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

  Future<void> _fetchStrippings() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection("Strippings")
          .get();

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

  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);

    final bool isBladeSelected =
        form.Blade.text.trim().toLowerCase() != "no";
    final bool isCreasingSelected =
        form.Creasing.text.trim().toLowerCase() != "no";
    final bool isPlySelected =
        form.PlyType.text.trim().toLowerCase() != "no";
    final bool isPerforationSelected =
        form.Perforation.text.trim().toLowerCase() != "no";
    final bool isZigZagBladeSelected =
        form.ZigZagBlade.text.trim().toLowerCase() != "no";
    final bool isRubberSelected =
        form.RubberType.text.trim().toLowerCase() != "no";
    final bool isHoleSelected =
        form.HoleType.text.trim().toLowerCase() != "no";

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
        title: const Text("Designer 2"),
        backgroundColor: Colors.yellow,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

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
              const SizedBox(height: 20),
            ],

          /// ✅ Ply
            if (form.canView("PlyType")) ...[
              _loadingPlys
                  ? const Center(child: CircularProgressIndicator())
                  : AddableSearchDropdown(
                label: "Ply",
                items: _plyItems,
                initialValue:
                form.PlyType.text.isEmpty ? "No" : form.PlyType.text,
                firestoreCollection: "Plys",  // ✅ saves new entries
                firestoreField: "Plys",       // ✅ field name in Firestore
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
                onAdd: (newItem) {
                  setState(() {
                    _plyItems.add(newItem);
                  });
                },
              ),
            ],

            const SizedBox(height: 20),

            /// ✅ Ply Selected By
            if (isPlySelected && form.canView("PlySelectedBy")) ...[
              const SizedBox(height: 20),
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

            if (form.canView("Blade")) const SizedBox(height: 20),

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

            if (form.canView("Creasing")) const SizedBox(height: 20),

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
                    form.PerforationSelectedBy.text = selectedByText();
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

            if (form.canView("Perforation")) const SizedBox(height: 20),

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
                    form.ZigZagBladeSelectedBy.text = selectedByText();
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

            if (form.canView("ZigZagBlade")) const SizedBox(height: 20),

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
                    form.RubberSelectedBy.text = selectedByText();
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

            if (form.canView("RubberType")) const SizedBox(height: 20),

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
                    form.HoleSelectedBy.text = selectedByText();
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

            if (form.canView("HoleType")) const SizedBox(height: 20),

            /// ✅ Stripping
            if (form.canView("StrippingType")) ...[
              _loadingStrippings
                  ? const Center(child: CircularProgressIndicator())
                  : AddableSearchDropdown(
                label: "Stripping",
                items: _strippingItems,
                initialValue: form.StrippingType.text.isEmpty
                    ? "No"
                    : form.StrippingType.text,
                firestoreCollection: "Strippings",
                firestoreField: "Strippings",
                onChanged: (v) {
                  setState(() {
                    form.StrippingType.text = (v ?? "No").trim();
                  });
                },
                onAdd: (newItem) {
                  setState(() {
                    _strippingItems.add(newItem);
                  });
                },
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }
}