import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lightatech/FormComponents/TextInput.dart';
import 'package:lightatech/FormComponents/SearchableDropdownWithInitial.dart';
import '../../../../../FormComponents/FlexibleToggle.dart';
import '../new_form_scope.dart';
import 'package:go_router/go_router.dart';


class ManualBendingPage extends StatefulWidget {
  const ManualBendingPage({super.key});

  @override
  State<ManualBendingPage> createState() => _ManualBendingPageState();
}

class _ManualBendingPageState extends State<ManualBendingPage> {
  bool loading = true;
  bool _loaded = false;
  bool manualbendingstatus=false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final form = NewFormScope.of(context);

    final lpm = form.LpmAutoIncrement.text;
    if (lpm.isEmpty) {
      setState(() => loading = false);
      return;
    }

    final snap = await FirebaseFirestore.instance
        .collection("jobs")
        .doc(lpm)
        .get();

    if (!snap.exists) {
      setState(() => loading = false);
      return;
    }

    final data = snap.data()!;
    final designer =
    Map<String, dynamic>.from(data["designer"]?["data"] ?? {});
    final manual =
    Map<String, dynamic>.from(data["manualBending"]?["data"] ?? {});

    /// 🔒 DESIGNER (VIEW ONLY)
    form.PartyName.text = designer["PartyName"] ?? "";
    form.ParticularJobName.text = designer["ParticularJobName"] ?? "";
    form.LpmAutoIncrement.text = lpm;

    /// ✏️ MANUAL BENDING (EDITABLE)
    form.ManualBendingCreatedBy.text =
        manual["ManualBendingCreatedBy"] ?? "";

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);

    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Manual Bending"),
        backgroundColor: Colors.yellow,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🔒 DESIGNER DATA (VIEW ONLY)
            TextInput(
              label: "Party Name",
              controller: form.PartyName,
              readOnly: true,
              hint: 'Name',
            ),
            const SizedBox(height: 20),

            TextInput(
              label: "Particular Job Name",
              controller: form.ParticularJobName,
              readOnly: true,
              hint: 'Job name',
            ),
            const SizedBox(height: 20),

            TextInput(
              label: "LPM Number",
              controller: form.LpmAutoIncrement,
              readOnly: true, hint: 'LPM NO.',
            ),

            const SizedBox(height: 30),

            FlexibleToggle(
              label: "Manual Bending *",
              inactiveText: "Pending",
              activeText: "Done",
              initialValue: manualbendingstatus,
              onChanged: (val) {
                setState(() {
                  manualbendingstatus = val;
                });

                form.ManualBendingStatus.text =
                val ? "Done" : "Pending";

                if (!val) {
                  form.ManualBendingCreatedBy.clear();
                }
              },
            ),
            const SizedBox(height: 30),

            /// ✏️ MANUAL BENDING (EDITABLE)
            SearchableDropdownWithInitial(
              label: "Manual Bending Created By",
              items: form.parties,
              initialValue: form.ManualBendingCreatedBy.text.isEmpty
                  ? "Select"
                  : form.ManualBendingCreatedBy.text,
              onChanged: (v) {
                setState(() {
                  form.ManualBendingCreatedBy.text = (v ?? "").trim();
                });
              },
            ),

            const SizedBox(height: 40),

            /// ✅ SAVE
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection("jobs")
                      .doc(form.LpmAutoIncrement.text)
                      .set({
                    "manualBending": {
                      "submitted": true,
                      "data": {
                        "ManualBendingStatus": form.ManualBendingStatus.text,
                        "ManualBendingCreatedBy":
                        form.ManualBendingCreatedBy.text,
                      },
                    },
                    "currentDepartment": "LaserCutting",
                    "updatedAt": FieldValue.serverTimestamp(),
                  }, SetOptions(merge: true));

                  context.pop(); // ✅ CORRECT
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Form submitted successfully")),
                  );
                  Navigator.pop(context);
                },

                child: const Text("Save & Continue"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
