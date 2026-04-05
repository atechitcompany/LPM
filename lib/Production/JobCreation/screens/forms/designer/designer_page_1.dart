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
  // 🚀 NAYA: Party Names ke sath unka Address yaad rakhne ke liye
  Map<String, String> clientAddresses = {};

  bool isLoading = true;
  bool _initialized = false;
  String? selectedJob;

  @override
  void initState() {
    super.initState();
    fetchClientNames();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    final form = NewFormScope.of(context);

    if (form.mode != "edit") {
      form.clearDesignerData();
    } else {
      _loadDesignerData(form);
    }
  }

  Future<void> _loadDesignerData(dynamic form) async {
    final uri = GoRouterState.of(context).uri;
    final dataJson = uri.queryParameters['data'];
    final lpmParam = uri.queryParameters['lpm'];

    if (lpmParam != null && lpmParam.isNotEmpty) {
      form.LpmAutoIncrement.text = lpmParam;
    }

    if (dataJson != null && dataJson.isNotEmpty) {
      try {
        final decodedData = jsonDecode(dataJson) as Map<String, dynamic>;
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
      } catch (e) {
        debugPrint("❌ Error decoding data: $e");
      }
    } else if (lpmParam != null && lpmParam.isNotEmpty) {
      try {
        final snap = await FirebaseFirestore.instance.collection("jobs").doc(lpmParam).get();
        if (!snap.exists) return;

        final decodedData = Map<String, dynamic>.from(snap.data()?["designer"]?["data"] ?? {});

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
      } catch (e) {
        debugPrint("❌ Error fetching from Firestore: $e");
      }
    }
  }

  Future<void> fetchClientNames() async {
    try {
      final query = await FirebaseFirestore.instance.collection('clients').get();
      final names = <String>[];

      for (var doc in query.docs) {
        var data = doc.data();
        var basicInfo = data['basic_info'] as Map<String, dynamic>? ?? {};

        String partyName = basicInfo['Party Names']?.toString() ?? '';
        // 🚀 NAYA: Data se Address nikalna
        String address = basicInfo['Address']?.toString() ?? '';

        if (partyName.isNotEmpty) {
          names.add(partyName);
          // Party ke naam ko uska address yaad dila diya memory mein
          clientAddresses[partyName] = address;
        }
      }

      names.sort();

      setState(() {
        userNames = names;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("❌ Error fetching client names: $e");
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
                  String selectedName = (v ?? "").trim();
                  form.PartyName.text = selectedName;

                  // 🚀 MAGIC YAHAN HAI: Agar naam select hua aur uska address majood hai toh auto-fill kardo
                  if (selectedName.isNotEmpty && clientAddresses.containsKey(selectedName)) {
                    form.DeliveryAt.text = clientAddresses[selectedName] ?? "";
                  }
                });
              },
            ),

            const SizedBox(height: 30),

            /// ✅ Delivery At (Yahan address automatically aa jayega)
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

                return AutoIncrementField(value: lpmText);
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}