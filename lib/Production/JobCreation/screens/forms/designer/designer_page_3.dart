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
  //TO-D2
  List<String> _bladeItems = ["No"];
  List<String> _creasingItems = ["No"];
  List<String> _capsuleItems = ["No"];
  bool _loadingBlades = true;
  bool _loadingCreasings = true;
  bool _loadingCapsules = true;
  //EN-D2
  List<String> _maleEmbossItems = ["No"];
  List<String> _femaleEmbossItems = ["No"];
  bool _loadingMaleEmboss = true;
  bool _loadingFemaleEmboss = true;

  @override
  void initState() {
    super.initState();
    //TO-D2
    _fetchBlades();
    _fetchCreasings();
    _fetchCapsules();
    //EN-D2
    _fetchMaleEmboss();
    _fetchFemaleEmboss();
  }
  //TO-D2
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
  //EN-D2

  Future<void> _fetchMaleEmboss() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection("Males Embosse")
          .get();

      final items = snap.docs
          .map((doc) {
        // Try both with and without trailing space
        final data = doc.data();
        final val = (data['Males Embosse '] ?? data['Males Embosse'] ?? '').toString().trim();
        return val;
      })
          .where((val) => val.isNotEmpty && val != "No")
          .toList();

      setState(() {
        _maleEmbossItems = ["No", ...items];
        _loadingMaleEmboss = false;
      });
    } catch (e) {
      debugPrint("❌ Error fetching Males Embosse: $e");
      setState(() => _loadingMaleEmboss = false);
    }
  }

  Future<void> _fetchFemaleEmboss() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection("Females Emobosse")
          .get();

      final items = snap.docs
          .map((doc) {
        final data = doc.data();
        final val = (data['Females Emobosse '] ?? data['Females Emobosse'] ?? '').toString().trim();
        return val;
      })
          .where((val) => val.isNotEmpty && val != "No")
          .toList();

      setState(() {
        _femaleEmbossItems = ["No", ...items];
        _loadingFemaleEmboss = false;
      });
    } catch (e) {
      debugPrint("❌ Error fetching Females Emobosse: $e");
      setState(() => _loadingFemaleEmboss = false);
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
          //TO-D2
          form.Blade.text = decodedData["Blade"] ?? "No";
          form.BladeSelectedBy.text = decodedData["BladeSelectedBy"] ?? "";
          form.Creasing.text = decodedData["Creasing"] ?? "No";
          form.CreasingSelectedBy.text = decodedData["CreasingSelectedBy"] ?? "";
          form.Unknown.text = decodedData["Unknown"] ?? "";
          form.CapsuleType.text = decodedData["CapsuleType"] ?? "";
          //EN-D2
          form.EmbossStatus.text = decodedData["EmbossStatus"] ?? "No";
          form.EmbossPcs.text = decodedData["EmbossPcs"] ?? "";
          form.MaleEmbossType.text = decodedData["MaleEmbossType"] ?? "";
          form.FemaleEmbossType.text = decodedData["FemaleEmbossType"] ?? "";
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
          //TO-D2
          form.Blade.text = decodedData["Blade"] ?? "No";
          form.BladeSelectedBy.text = decodedData["BladeSelectedBy"] ?? "";
          form.Creasing.text = decodedData["Creasing"] ?? "No";
          form.CreasingSelectedBy.text = decodedData["CreasingSelectedBy"] ?? "";
          form.Unknown.text = decodedData["Unknown"] ?? "";
          form.CapsuleType.text = decodedData["CapsuleType"] ?? "";
          //EN-D2
          form.EmbossStatus.text = decodedData["EmbossStatus"] ?? "No";
          form.EmbossPcs.text = decodedData["EmbossPcs"] ?? "";
          form.MaleEmbossType.text = decodedData["MaleEmbossType"] ?? "";
          form.FemaleEmbossType.text = decodedData["FemaleEmbossType"] ?? "";
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
              const SizedBox(height: 20),
            ],

            /// ✅ Emboss Pcs
            if (form.canView("EmbossPcs")) ...[
              TextInput(
                label: "Emboss Pcs",
                hint: "No of Pcs",
                controller: form.EmbossPcs,
              ),
              const SizedBox(height: 20),
            ],

            if (form.canView("MaleEmbossType")) ...[
              _loadingMaleEmboss
                  ? const Center(child: CircularProgressIndicator())
                  : AddableSearchDropdown(
                label: "Male Emboss",
                items: _maleEmbossItems,
                initialValue: form.MaleEmbossType.text.isEmpty ? "No" : form.MaleEmbossType.text,
                firestoreCollection: "Males Embosse",
                firestoreField: "Males Embosse",
                onChanged: (v) {
                  setState(() {
                    form.MaleEmbossType.text = v ?? "";
                  });
                },
                onAdd: (newItem) {
                  setState(() {
                    _maleEmbossItems.add(newItem);
                  });
                },
              ),
              const SizedBox(height: 30),
            ],

            /// ✅ Female Emboss
            if (form.canView("FemaleEmbossType")) ...[
              _loadingFemaleEmboss
                  ? const Center(child: CircularProgressIndicator())
                  : AddableSearchDropdown(
                label: "Female Emboss",
                items: _femaleEmbossItems,
                initialValue: form.FemaleEmbossType.text.isEmpty ? "No" : form.FemaleEmbossType.text,
                firestoreCollection: "Females Emobosse",
                firestoreField: "Females Emobosse",
                onChanged: (v) {
                  setState(() {
                    form.FemaleEmbossType.text = v ?? "";
                  });
                },
                onAdd: (newItem) {
                  setState(() {
                    _femaleEmbossItems.add(newItem);
                  });
                },
              ),
              const SizedBox(height: 30),
            ],

            /// ✅ Micro Serration – Half Cut
            if (form.canView("MicroSerrationHalfCut")) ...[
              FlexibleToggle(
                label: "Micro serration Half cut 23.60",
                inactiveText: "No",
                activeText: "Yes",
                initialValue: false,
                onChanged: (val) {},
              ),
              const SizedBox(height: 20),
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
              const SizedBox(height: 20),
            ],

          ],
        ),
      ),
    );
  }
}