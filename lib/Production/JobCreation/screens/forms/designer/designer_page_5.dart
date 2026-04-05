import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../new_form_scope.dart';
import 'package:lightatech/FormComponents/AddableSearchDropdown.dart';
import 'package:lightatech/FormComponents/NumberStepper.dart';
import 'dart:convert';

class DesignerPage5 extends StatefulWidget {
  const DesignerPage5({super.key});

  @override
  State<DesignerPage5> createState() => _DesignerPage5State();
}

class _DesignerPage5State extends State<DesignerPage5> {
  bool _initialized = false;

  List<String> _maleEmbossItems = ["No"];
  List<String> _femaleEmbossItems = ["No"];
  bool _loadingMaleEmboss = true;
  bool _loadingFemaleEmboss = true;

  @override
  void initState() {
    super.initState();
    _fetchMaleEmboss();
    _fetchFemaleEmboss();
  }

  // 🚀 FETCH 1: Male Emboss from master_inventory
  Future<void> _fetchMaleEmboss() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection("master_inventory") // ✅ UPDATED
          .get();

      final items = snap.docs
          .map((doc) {
        final data = doc.data();
        // Master inventory mein jo column ka naam hai wahi yahan check kar rahe hain
        final val = (data['Males Embosse '] ?? data['Males Embosse'] ?? '').toString().trim();
        return val;
      })
          .where((val) => val.isNotEmpty && val != "No")
          .toList();

      setState(() {
        _maleEmbossItems = ["No", ...items.toSet().toList()..sort()];
        _loadingMaleEmboss = false;
      });
    } catch (e) {
      debugPrint("❌ Error fetching Males Embosse: $e");
      setState(() => _loadingMaleEmboss = false);
    }
  }

  // 🚀 FETCH 2: Female Emboss from master_inventory
  Future<void> _fetchFemaleEmboss() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection("master_inventory") // ✅ UPDATED
          .get();

      final items = snap.docs
          .map((doc) {
        final data = doc.data();
        // Master inventory mein jo column ka naam hai wahi yahan check kar rahe hain
        final val = (data['Females Emobosse '] ?? data['Females Emobosse'] ?? '').toString().trim();
        return val;
      })
          .where((val) => val.isNotEmpty && val != "No")
          .toList();

      setState(() {
        _femaleEmbossItems = ["No", ...items.toSet().toList()..sort()];
        _loadingFemaleEmboss = false;
      });
    } catch (e) {
      debugPrint("❌ Error fetching Females Emobosse: $e");
      setState(() => _loadingFemaleEmboss = false);
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
          form.MaleEmbossType.text = decodedData["MaleEmbossType"] ?? "";

          form.XYSize.text = decodedData["XYSize"] ?? "";
          form.FemaleEmbossType.text = decodedData["FemaleEmbossType"] ?? "";

          form.XY2Size.text = decodedData["XY2Size"] ?? "";
        });

        debugPrint("✅ DesignerPage5 loaded data from route");
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
          form.MaleEmbossType.text = decodedData["MaleEmbossType"] ?? "";

          form.XYSize.text = decodedData["XYSize"] ?? "";
          form.FemaleEmbossType.text = decodedData["femaleEmbossType"] ?? "";

          form.XY2Size.text = decodedData["XY2Size"] ?? "";
        });

        debugPrint("✅ DesignerPage5 loaded data from Firestore");
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
        title: const Text("Designer 5"),
        backgroundColor: Colors.yellow,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// ✅ Male Emboss
            if (form.canView("MaleEmbossType")) ...[
              _loadingMaleEmboss
                  ? const Center(child: CircularProgressIndicator())
                  : AddableSearchDropdown(
                label: "Male Emboss",
                items: _maleEmbossItems,
                initialValue: form.MaleEmbossType.text.isEmpty ? "No" : form.MaleEmbossType.text,
                firestoreCollection: "master_inventory", // ✅ UPDATED
                firestoreField: "Males Embosse",         // ✅ UPDATED
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
                firestoreCollection: "master_inventory", // ✅ UPDATED
                firestoreField: "Females Emobosse",      // ✅ UPDATED
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

            /// ✅ X2



          ],
        ),
      ),
    );
  }
}