import 'package:flutter/material.dart';
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
        form.MaleEmbossType.text = decodedData["maleEmbossType"] ?? "";
        form.X.text = decodedData["x"] ?? "";
        form.Y.text = decodedData["y"] ?? "";
        form.XYSize.text = decodedData["xySize"] ?? "";
        form.FemaleEmbossType.text = decodedData["femaleEmbossType"] ?? "";
        form.X2.text = decodedData["x2"] ?? "";
        form.Y2.text = decodedData["y2"] ?? "";
        form.XY2Size.text = decodedData["xy2Size"] ?? "";
      });

      debugPrint("✅ DesignerPage5 loaded data from route");
    } catch (e) {
      debugPrint("❌ Error decoding data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
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
              AddableSearchDropdown(
                label: "Male Emboss",
                items: form.embossTypes,
                initialValue: form.MaleEmbossType.text.isEmpty ? "No" : form.MaleEmbossType.text,
                onAdd: (newJob) => form.embossTypes.add(newJob),
                onChanged: (v) {
                  form.MaleEmbossType.text = v ?? "";
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
              AddableSearchDropdown(
                label: "Female Emboss",
                items: form.embossTypes,
                initialValue: form.FemaleEmbossType.text.isEmpty ? "No" : form.FemaleEmbossType.text,
                onAdd: (newJob) => form.embossTypes.add(newJob),
                onChanged: (v) {
                  form.FemaleEmbossType.text = v ?? "";
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