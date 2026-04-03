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
          form.X.text = decodedData["X"] ?? "";
          form.Y.text = decodedData["Y"] ?? "";
          form.XYSize.text = decodedData["XYSize"] ?? "";
          form.FemaleEmbossType.text = decodedData["FemaleEmbossType"] ?? "";
          form.X2.text = decodedData["X2"] ?? "";
          form.Y2.text = decodedData["Y2"] ?? "";
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
          form.X.text = decodedData["X"] ?? "";
          form.Y.text = decodedData["Y"] ?? "";
          form.XYSize.text = decodedData["XYSize"] ?? "";
          form.FemaleEmbossType.text = decodedData["femaleEmbossType"] ?? "";
          form.X2.text = decodedData["X2"] ?? "";
          form.Y2.text = decodedData["Y2"] ?? "";
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

            /// ✅ X
            if (form.canView("X")) ...[
              const Text(
                "X",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              NumberStepper(
                step: 0.01,
                controller: form.X,
                onChanged: (val) {
                  form.X.text = val.toString();
                  form.calculateXY();
                },
              ),
              const SizedBox(height: 30),
            ],

            /// ✅ Y
            if (form.canView("Y")) ...[
              const Text(
                "Y",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              NumberStepper(
                step: 0.01,
                controller: form.Y,
                onChanged: (val) {
                  form.Y.text = val.toString();
                  form.calculateXY();
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

            /// ✅ X2
            if (form.canView("X2")) ...[
              const Text(
                "X2",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              NumberStepper(
                step: 0.01,
                controller: form.X2,
                onChanged: (val) {
                  form.X2.text = val.toString();
                  form.calculateXY2();
                },
              ),
              const SizedBox(height: 30),
            ],

            /// ✅ Y2
            if (form.canView("Y2")) ...[
              const Text(
                "Y2",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              NumberStepper(
                step: 0.01,
                controller: form.Y2,
                onChanged: (val) {
                  form.Y2.text = val.toString();
                  form.calculateXY2();
                },
              ),
              const SizedBox(height: 30),
            ],
          ],
        ),
      ),
    );
  }
}