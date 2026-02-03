import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lightatech/FormComponents/SearchableDropdownWithInitial.dart';
import '../../../../../FormComponents/AddableSearchDropdown.dart';
import '../../../../../FormComponents/AutoIncrementField.dart';
import '../../../../../FormComponents/TextInput.dart';
import '../new_form_scope.dart';

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
    // ✏️ EDIT MODE → LOAD DATA
    else {
      _loadDesignerData(form);
    }
  }


  Future<void> _loadDesignerData(dynamic form) async {
    final lpm = form.lpm;
    if (lpm == null) return;

    final snap = await FirebaseFirestore.instance
        .collection("jobs")
        .doc(lpm)
        .get();

    if (!snap.exists) return;

    final data = snap.data()!;
    final designer =
    Map<String, dynamic>.from(data["designer"]?["data"] ?? {});

    form.PartyName.text = designer["PartyName"] ?? "";
    form.DesignerCreatedBy.text =
        designer["DesignerCreatedBy"] ?? "";
    form.DeliveryAt.text = designer["DeliveryAt"] ?? "";
    form.Orderby.text = designer["Orderby"] ?? "";
    selectedJob = designer["ParticularJobName"];
    form.ParticularJobName.text = selectedJob ?? "";

    form.Priority.text = designer["Priority"] ?? "";
    form.Remark.text = designer["Remark"] ?? "";



    // LPM must be preserved
    form.LpmAutoIncrement.text = lpm.toString();
    if (mounted) setState(() {});
    debugPrint("DesignerPage1 MODE = ${form.mode}");
    debugPrint("DesignerPage1 LPM = ${form.lpm}");

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

            /// ✅ Designer Created By
            /// ✅ Designer Created By
            if (form.canView("DesignerCreatedBy"))
              SearchableDropdownWithInitial(
                label: "Designer Created By",
                items: form.parties,
                initialValue: form.DesignerCreatedBy.text.isEmpty
                    ? "Select"
                    : form.DesignerCreatedBy.text,
                onChanged: (v) {
                  setState(() {
                    form.DesignerCreatedBy.text = (v ?? "").trim();
                  });
                },
              ),

            if (form.canView("DesignerCreatedBy"))
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
              controller: form.Orderby,
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
                final lpm =
                    int.tryParse(form.LpmAutoIncrement.text) ?? 0;

                if (lpm == 0) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                return AutoIncrementField(value: lpm);
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
