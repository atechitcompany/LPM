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

  @override
  void initState() {
    super.initState();
    fetchUserNames();
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
              initialValue: null, // ✅ IMPORTANT
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
              initialValue: form.ParticularJobName.text.isEmpty
                  ? "Select Job"
                  : form.ParticularJobName.text,
              onChanged: (v) {
                setState(() {
                  form.ParticularJobName.text = (v ?? "").trim();
                });
              },
              onAdd: (newJob) => form.jobs.add(newJob),
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
