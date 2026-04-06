import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../new_form_scope.dart';
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

  @override
  void initState() {
    super.initState();
    _fetchPlys();
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
    final bool isPlySelected =
        form.PlyType.text.trim().toLowerCase() != "no";
    final lpmParam = GoRouterState.of(context).uri.queryParameters['lpm'] ?? '';

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

            /// ✅ Priority
            if (form.canView("Priority")) ...[
              const Text(
                "Priority",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              PrioritySelector(
                initialValue: form.Priority.text,
                onChanged: (v) {
                  form.Priority.text = v ?? "";
                },
              ),
              const SizedBox(height: 30),
            ],

            /// ✅ Remark
            if (form.canView("Remark")) ...[
              TextInput(
                label: "Remark",
                hint: "Remark",
                controller: form.Remark,
              ),
              const SizedBox(height: 30),
            ],

            /// ✅ Drawing Attachment
            if (form.canView("DrawingAttachment")) ...[
              const Text(
                "Drawing Attachment",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              FileUploadBox(
                jobId:     lpmParam,                // ✅
                fieldName: 'DrawingAttachment',     // ✅ unique name per field
                onFileSelected: (file) {
                  debugPrint("Drawing: ${file.name}");
                },
              ),
              const SizedBox(height: 30),
            ],

            /// ✅ Rubber Report (only when designing done)
            if (isDesigningDone && form.canView("RubberReport")) ...[
              const Text(
                "Rubber Report",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              FileUploadBox(
                jobId:     lpmParam,
                fieldName: 'RubberReport',          // ✅ different name
                onFileSelected: (file) {
                  debugPrint("Rubber: ${file.name}");
                },
              ),
              const SizedBox(height: 30),
            ],

            /// ✅ Punch Report
            if (form.canView("PunchReport")) ...[
              const Text(
                "Punch Report",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              FileUploadBox(
                jobId:     lpmParam,
                fieldName: 'PunchReport',           // ✅ different name
                onFileSelected: (file) {
                  debugPrint("Punch: ${file.name}");
                },
              ),
              const SizedBox(height: 30),
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

            /// ✅ Ply Selected By
            if (isPlySelected && form.canView("PlySelectedBy")) ...[
              const SizedBox(height: 30),
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
          ],
        ),
      ),
    );
  }
}