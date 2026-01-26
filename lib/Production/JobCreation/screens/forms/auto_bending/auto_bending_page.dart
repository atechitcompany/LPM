import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:lightatech/FormComponents/TextInput.dart';
import 'package:lightatech/FormComponents/SearchableDropdownWithInitial.dart';
import 'package:lightatech/FormComponents/FlexibleToggle.dart';

import '../new_form_scope.dart';

class AutoBendingPage extends StatefulWidget {
  const AutoBendingPage({super.key});

  @override
  State<AutoBendingPage> createState() => _AutoBendingPageState();
}

class _AutoBendingPageState extends State<AutoBendingPage> {
  bool loading = true;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_loaded) return;
    _loaded = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryLoad();
    });
  }

  Future<void> _tryLoad() async {
    final form = NewFormScope.of(context);

    if (form.LpmAutoIncrement.text.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) _tryLoad();
      return;
    }

    await _loadDesignerData(form);
  }

  /// ✅ FIX: use `dynamic`, NOT `NewFormState`
  Future<void> _loadDesignerData(dynamic form) async {
    final uri = GoRouterState.of(context).uri;
    final lpm = uri.queryParameters['lpm'];

    if (lpm == null) {
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
    final autoBending =
    Map<String, dynamic>.from(data["autoBending"]?["data"] ?? {});

    // 🔒 DESIGNER (VIEW ONLY)
    form.PartyName.text = designer["PartyName"] ?? "";
    form.DeliveryAt.text = designer["DeliveryAt"] ?? "";
    form.Orderby.text = designer["Orderby"] ?? "";
    form.ParticularJobName.text =
        designer["ParticularJobName"] ?? "";
    form.Priority.text = designer["Priority"] ?? "";

    // 🔒 LPM
    form.LpmAutoIncrement.text = lpm;

    // ✏️ AUTOBENDING
    form.AutoBendingCreatedBy.text =
        autoBending["AutoBendingCreatedBy"] ?? "";

    form.AutoCreasing = autoBending["AutoCreasing"] == true;
    form.AutoCreasingStatus.text =
        autoBending["AutoCreasingStatus"] ?? "Pending";

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
        title: const Text("Autobending"),
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
              hint: "",
              controller: form.PartyName,
              readOnly: true,
            ),
            const SizedBox(height: 20),

            TextInput(
              label: "Delivery At",
              hint: "",
              controller: form.DeliveryAt,
              readOnly: true,
            ),
            const SizedBox(height: 20),

            TextInput(
              label: "Order By",
              hint: "",
              controller: form.Orderby,
              readOnly: true,
            ),
            const SizedBox(height: 20),

            TextInput(
              label: "Particular Job Name",
              hint: "",
              controller: form.ParticularJobName,
              readOnly: true,
            ),
            const SizedBox(height: 20),

            TextInput(
              label: "LPM Number",
              hint: "",
              controller: form.LpmAutoIncrement,
              readOnly: true,
            ),
            const SizedBox(height: 20),

            TextInput(
              label: "Priority",
              hint: "",
              controller: form.Priority,
              readOnly: true,
            ),

            const SizedBox(height: 30),

            /// ✏️ AUTOBENDING (EDITABLE)
            SearchableDropdownWithInitial(
              label: "Auto Bending Created By",
              items: form.parties,
              initialValue: form.AutoBendingCreatedBy.text.isEmpty
                  ? "Select"
                  : form.AutoBendingCreatedBy.text,
              onChanged: (v) {
                setState(() {
                  form.AutoBendingCreatedBy.text = (v ?? "").trim();
                });
              },
            ),
            const SizedBox(height: 30),

            FlexibleToggle(
              label: "Auto Creasing",
              inactiveText: "No",
              activeText: "Yes",
              initialValue: form.AutoCreasing,
              onChanged: (v) {
                setState(() {
                  form.AutoCreasing = v;
                });
              },
            ),

            if (form.AutoCreasing) ...[
              const SizedBox(height: 20),
              FlexibleToggle(
                label: "Auto Creasing Status",
                inactiveText: "Pending",
                activeText: "Done",
                initialValue:
                form.AutoCreasingStatus.text.toLowerCase() == "done",
                onChanged: (v) {
                  form.AutoCreasingStatus.text =
                  v ? "Done" : "Pending";
                },
              ),
            ],

            const SizedBox(height: 40),

            /// ✅ SAVE & CONTINUE
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection("jobs")
                      .doc(form.LpmAutoIncrement.text)
                      .set({
                    "autoBending": {
                      "submitted": true,
                      "data": {
                        "AutoBendingCreatedBy":
                        form.AutoBendingCreatedBy.text,
                        "AutoCreasing": form.AutoCreasing,
                        "AutoCreasingStatus":
                        form.AutoCreasingStatus.text,
                      },
                    },
                    "currentDepartment": "LaserCutting",
                    "updatedAt": FieldValue.serverTimestamp(),
                  }, SetOptions(merge: true));

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
