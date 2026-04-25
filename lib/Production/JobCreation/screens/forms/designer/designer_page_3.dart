import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../new_form_scope.dart';
import 'package:lightatech/FormComponents/SearchableDropdownWithInitial.dart';
import 'package:lightatech/FormComponents/FlexibleToggle.dart';
import 'package:lightatech/FormComponents/TextInput.dart';
import 'package:lightatech/FormComponents/AddableSearchDropdown.dart';
import 'dart:convert';

// Import shared widgets from page1
import 'designer_page_1.dart';
import 'designer_widgets.dart';

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

  List<String> _maleEmbossItems = ["No"];
  List<String> _femaleEmbossItems = ["No"];
  bool _loadingMaleEmboss = true;
  bool _loadingFemaleEmboss = true;

  @override
  void initState() {
    super.initState();
    _fetchBlades();
    _fetchCreasings();
    _fetchCapsules();
    _fetchMaleEmboss();
    _fetchFemaleEmboss();
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

  Future<void> _fetchMaleEmboss() async {
    try {
      final snap =
      await FirebaseFirestore.instance.collection("Males Embosse").get();
      final items = snap.docs
          .map((doc) {
        final data = doc.data();
        final val =
        (data['Males Embosse '] ?? data['Males Embosse'] ?? '')
            .toString()
            .trim();
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
        final val =
        (data['Females Emobosse '] ?? data['Females Emobosse'] ?? '')
            .toString()
            .trim();
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
          form.Blade.text = decodedData["Blade"] ?? "No";
          form.BladeSelectedBy.text = decodedData["BladeSelectedBy"] ?? "";
          form.Creasing.text = decodedData["Creasing"] ?? "No";
          form.CreasingSelectedBy.text = decodedData["CreasingSelectedBy"] ?? "";
          form.Unknown.text = decodedData["Unknown"] ?? "";
          form.CapsuleType.text = decodedData["CapsuleType"] ?? "";
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
          form.Blade.text = decodedData["Blade"] ?? "No";
          form.BladeSelectedBy.text = decodedData["BladeSelectedBy"] ?? "";
          form.Creasing.text = decodedData["Creasing"] ?? "No";
          form.CreasingSelectedBy.text = decodedData["CreasingSelectedBy"] ?? "";
          form.Unknown.text = decodedData["Unknown"] ?? "";
          form.CapsuleType.text = decodedData["CapsuleType"] ?? "";
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
          child: DesignerStepHeader(currentStep: 3),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Emboss Toggle ────────────────────────────────────────────────
            if (form.canView("EmbossStatus"))
              fieldCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionLabel("Emboss"),
                    FlexibleToggle(
                      label: "",
                      inactiveText: "No",
                      activeText: "Yes",
                      initialValue:
                      form.EmbossStatus.text.toLowerCase() == "yes",
                      onChanged: (v) {
                        form.EmbossStatus.text = v ? "Yes" : "No";
                      },
                    ),
                  ],
                ),
              ),

            // ── Emboss Pcs ───────────────────────────────────────────────────
            if (form.canView("EmbossPcs"))
              fieldCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionLabel("Emboss Pcs"),
                    TextInput(
                      label: "",
                      hint: "No of Pcs",
                      controller: form.EmbossPcs,
                    ),
                  ],
                ),
              ),

            // ── Male Emboss ──────────────────────────────────────────────────
            if (form.canView("MaleEmbossType"))
              fieldCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionLabel("Male Emboss"),
                    _loadingMaleEmboss
                        ? const Center(child: CircularProgressIndicator())
                        : AddableSearchDropdown(
                      label: "",
                      items: _maleEmbossItems,
                      initialValue: form.MaleEmbossType.text.isEmpty
                          ? "No"
                          : form.MaleEmbossType.text,
                      firestoreCollection: "Males Embosse",
                      firestoreField: "Males Embosse",
                      onChanged: (v) =>
                          setState(() => form.MaleEmbossType.text = v ?? ""),
                      onAdd: (newItem) =>
                          setState(() => _maleEmbossItems.add(newItem)),
                    ),
                  ],
                ),
              ),

            // ── Female Emboss ────────────────────────────────────────────────
            if (form.canView("FemaleEmbossType"))
              fieldCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionLabel("Female Emboss"),
                    _loadingFemaleEmboss
                        ? const Center(child: CircularProgressIndicator())
                        : AddableSearchDropdown(
                      label: "",
                      items: _femaleEmbossItems,
                      initialValue: form.FemaleEmbossType.text.isEmpty
                          ? "No"
                          : form.FemaleEmbossType.text,
                      firestoreCollection: "Females Emobosse",
                      firestoreField: "Females Emobosse",
                      onChanged: (v) =>
                          setState(() => form.FemaleEmbossType.text = v ?? ""),
                      onAdd: (newItem) =>
                          setState(() => _femaleEmbossItems.add(newItem)),
                    ),
                  ],
                ),
              ),

            // ── Micro Serration – Half Cut ───────────────────────────────────
            if (form.canView("MicroSerrationHalfCut"))
              fieldCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionLabel("Micro Serration Half Cut 23.60"),
                    FlexibleToggle(
                      label: "",
                      inactiveText: "No",
                      activeText: "Yes",
                      initialValue: false,
                      onChanged: (val) {},
                    ),
                  ],
                ),
              ),

            // ── Micro Serration – Creasing ───────────────────────────────────
            if (form.canView("MicroSerrationCreasing"))
              fieldCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionLabel("Micro Serration Creasing 23.60"),
                    FlexibleToggle(
                      label: "",
                      inactiveText: "No",
                      activeText: "Yes",
                      initialValue: false,
                      onChanged: (val) {},
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