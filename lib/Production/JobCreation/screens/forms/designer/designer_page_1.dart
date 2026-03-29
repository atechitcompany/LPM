import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:lightatech/FormComponents/SearchableDropdownWithInitial.dart';
import '../../../../../FormComponents/AddableSearchDropdown.dart';
import '../../../../../FormComponents/AutoIncrementField.dart';
import '../../../../../FormComponents/TextInput.dart';
import '../new_form_scope.dart';
import 'dart:convert';

class DesignerPage1 extends StatefulWidget {
  const DesignerPage1({super.key});

  @override
  State<DesignerPage1> createState() => _DesignerPage1State();
}

class _DesignerPage1State extends State<DesignerPage1> {
  List<String> userNames = [];
  bool isLoading = true;
  bool _initialized = false;
  String? selectedJob;


  @override
  void initState() {
    super.initState();
    fetchUserNames();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    final form = NewFormScope.of(context);

    // 🆕 CREATE MODE → CLEAR FORM
    if (form.mode != "edit") {
      form.clearDesignerData();
    }
    // ✏️ EDIT MODE → LOAD DATA FROM ROUTE PARAMETERS
    else {
      _loadDesignerData(form);
    }
  }


  Future<void> _loadDesignerData(dynamic form) async {
    // ✅ NEW: Get data from route parameters instead of Firestore
    final uri = GoRouterState.of(context).uri;
    final dataJson = uri.queryParameters['data'];
    final lpmParam = uri.queryParameters['lpm'];

    debugPrint("✅ DesignerPage1 - Received data from route: $dataJson");
    debugPrint("✅ LPM Parameter: $lpmParam");

    // ✅ SET LPM FIRST (critical for submission)
    if (lpmParam != null && lpmParam.isNotEmpty) {
      form.LpmAutoIncrement.text = lpmParam;
      debugPrint("✅ Set LPM to: $lpmParam");
    } else {
      // If no LPM in route, this shouldn't happen in edit mode
      debugPrint("⚠️ No LPM found in route parameter");
    }

    if (dataJson != null && dataJson.isNotEmpty) {
      try {
        // Decode JSON data
        final decodedData = jsonDecode(dataJson) as Map<String, dynamic>;

        debugPrint("✅ Decoded data: ${decodedData.keys.toList()}");

        // ✅ Populate form fields from decoded data (using camelCase keys)
        setState(() {
          form.PartyName.text = decodedData["PartyName"] ?? "";
          form.DesignerCreatedBy.text = decodedData["DesignerCreatedBy"] ?? "";
          form.DeliveryAt.text = decodedData["DeliveryAt"] ?? "";
          form.OrderBy.text = decodedData["Orderby"] ?? "";
          form.ParticularJobName.text = decodedData["particularJobName"] ?? decodedData["ParticularJobName"] ?? "";
          selectedJob = decodedData["particularJobName"] ?? decodedData["ParticularJobName"];
          form.Priority.text = decodedData["Priority"] ?? "";
          form.Remark.text = decodedData["Remark"] ?? "";


        });

        debugPrint("✅ DesignerPage1 loaded data from route parameters");
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
          form.PartyName.text = decodedData["PartyName"] ?? "";
          form.DesignerCreatedBy.text = decodedData["DesignerCreatedBy"] ?? "";
          form.DeliveryAt.text = decodedData["DeliveryAt"] ?? "";
          // CORRECT
          form.OrderBy.text = decodedData["Orderby"] ?? "";
          form.ParticularJobName.text = decodedData["particularJobName"] ?? decodedData["ParticularJobName"] ?? "";
          selectedJob = decodedData["particularJobName"] ?? decodedData["ParticularJobName"];
          form.Priority.text = decodedData["Priority"] ?? "";
          form.Remark.text = decodedData["Remark"] ?? "";


        });

        debugPrint("✅ DesignerPage1 loaded data from Firestore");
      } catch (e) {
        debugPrint("❌ Error fetching from Firestore: $e");
      }
    } else {
      debugPrint("❌ No data in route parameters and no LPM, skipping load");
    }
  }


  Future<void> fetchUserNames() async {
    try {
      final query =
      await FirebaseFirestore.instance.collection('Onboarding').get();

      final names = query.docs
          .map((doc) => doc['Username']?.toString() ?? '')
          .where((name) => name.isNotEmpty)
          .toList();

      names.sort();

      setState(() {
        userNames = names; // ✅ NO "Select Party"
        isLoading = false;
      });
    } catch (e) {
      debugPrint("❌ Error fetching usernames: $e");
      setState(() {
        userNames = [];
        isLoading = false;
      });
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
        title: const Text("Designer 1"),
        backgroundColor: Colors.yellow,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ✅ Party Name *
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : SearchableDropdownWithInitial(
              label: "Party Name *",
              items: userNames,
              initialValue: form.PartyName.text.isEmpty
                  ? null
                  : form.PartyName.text,
              onChanged: (v) {
                setState(() {
                  form.PartyName.text = (v ?? "").trim();
                });
              },
            ),




            const SizedBox(height: 30),



            /// ✅ Delivery At
            TextInput(
              controller: form.DeliveryAt,
              label: "Delivery At",
              hint: "Address",
            ),

            const SizedBox(height: 30),

            /// ✅ Order By
            TextInput(
              controller: form.OrderBy,
              label: "Order By",
              hint: "Name",
            ),

            const SizedBox(height: 30),

            /// ✅ Particular Job Name *
            AddableSearchDropdown(
              label: "Particular Job Name *",
              items: form.jobs,
              initialValue: selectedJob,
              onChanged: (v) {
                setState(() {
                  selectedJob = v;
                  form.ParticularJobName.text = (v ?? "").trim();
                });
              },
              onAdd: (newJob) {
                setState(() {
                  form.jobs.add(newJob);
                  selectedJob = newJob;
                  form.ParticularJobName.text = newJob;
                });
              },
            ),


            const SizedBox(height: 30),

            /// ✅ LPM Auto Increment
            ValueListenableBuilder(
              valueListenable: form.LpmAutoIncrement,
              builder: (context, value, child) {
                final lpmText = form.LpmAutoIncrement.text.trim();

                if (lpmText.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                return AutoIncrementField(value: lpmText); // ← pass the string directly
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}