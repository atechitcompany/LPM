import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:lightatech/FormComponents/SearchableDropdownWithInitial.dart';
import '../../../../../FormComponents/AddableSearchDropdown.dart';
import '../../../../../FormComponents/AutoIncrementField.dart';
import '../../../../../FormComponents/TextInput.dart';
import 'package:lightatech/FormComponents/PrioritySelector.dart';
import '../new_form_scope.dart';
import 'dart:convert';

// ─── Shared Step-Header Widget ───────────────────────────────────────────────

class DesignerStepHeader extends StatelessWidget {
  final int currentStep; // 1-based

  const DesignerStepHeader({super.key, required this.currentStep});

  static const _labels = [
    'Designer\nInfo',
    'Materials\n& Tools',
    'Emboss\n& More',
    'Status\n& Submit',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Step labels row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: List.generate(_labels.length, (i) {
                final stepNum = i + 1;
                final isActive = stepNum == currentStep;
                final isDone = stepNum < currentStep;
                return Expanded(
                  child: Column(
                    children: [
                      Text(
                        _labels[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                          color: isActive
                              ? Colors.black
                              : isDone
                              ? Colors.black54
                              : Colors.black38,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
          // Progress bar
          Row(
            children: List.generate(_labels.length, (i) {
              final stepNum = i + 1;
              final isActive = stepNum == currentStep;
              final isDone = stepNum < currentStep;
              return Expanded(
                child: Container(
                  height: 3,
                  color: isActive || isDone
                      ? const Color(0xFFF8D94B)
                      : Colors.grey.shade200,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Section label helper ─────────────────────────────────────────────────────

Widget _sectionLabel(String text) => Padding(
  padding: const EdgeInsets.only(bottom: 6),
  child: Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: Colors.black87,
      letterSpacing: 0.1,
    ),
  ),
);

// ─── Card wrapper for each field group ───────────────────────────────────────

Widget _fieldCard({required Widget child}) => Container(
  margin: const EdgeInsets.only(bottom: 16),
  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Colors.grey.shade200),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: child,
);

// ─── Page 1 ──────────────────────────────────────────────────────────────────

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
  Map<String, String> clientAddresses = {};

  @override
  void initState() {
    super.initState();
    fetchClientData().then((_) {
      final form = NewFormScope.of(context);
      if (form.mode == "edit") {
        _loadDesignerData(form);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    final form = NewFormScope.of(context);

    if (form.mode != "edit") {
      form.clearDesignerData();
    }
  }

  Future<void> _loadDesignerData(dynamic form) async {
    final uri = GoRouterState.of(context).uri;
    final dataJson = uri.queryParameters['data'];
    final lpmParam = uri.queryParameters['lpm'];

    debugPrint("✅ DesignerPage1 - Received data from route: $dataJson");
    debugPrint("✅ LPM Parameter: $lpmParam");

    if (lpmParam != null && lpmParam.isNotEmpty) {
      form.LpmAutoIncrement.text = lpmParam;
      debugPrint("✅ Set LPM to: $lpmParam");
    } else {
      debugPrint("⚠️ No LPM found in route parameter");
    }

    if (dataJson != null && dataJson.isNotEmpty) {
      try {
        final decodedData = jsonDecode(dataJson) as Map<String, dynamic>;

        final party = (decodedData["PartyName"] ?? "").trim();
        final routeDelivery = (decodedData["DeliveryAt"] ?? "").trim();

        setState(() {
          form.PartyName.text = party;
          form.DesignerCreatedBy.text = decodedData["DesignerCreatedBy"] ?? "";
          form.DeliveryAt.text = routeDelivery.isNotEmpty
              ? routeDelivery
              : (clientAddresses[party] ?? "");
          form.OrderBy.text = decodedData["Orderby"] ?? "";
          form.ParticularJobName.text =
              decodedData["particularJobName"] ?? decodedData["ParticularJobName"] ?? "";
          selectedJob = form.ParticularJobName.text;
          form.Priority.text = decodedData["Priority"] ?? "";
          form.Remark.text = decodedData["Remark"] ?? "";
        });
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

        final party = (decodedData["PartyName"] ?? "").trim();
        final firestoreDelivery = (decodedData["DeliveryAt"] ?? "").trim();

        setState(() {
          form.PartyName.text = party;
          form.DesignerCreatedBy.text = decodedData["DesignerCreatedBy"] ?? "";
          form.DeliveryAt.text = firestoreDelivery.isNotEmpty
              ? firestoreDelivery
              : (clientAddresses[party] ?? "");
          form.OrderBy.text = decodedData["Orderby"] ?? "";
          form.ParticularJobName.text =
              decodedData["particularJobName"] ?? decodedData["ParticularJobName"] ?? "";
          selectedJob = form.ParticularJobName.text;
          form.Priority.text = decodedData["Priority"] ?? "";
          form.Remark.text = decodedData["Remark"] ?? "";
        });
      } catch (e) {
        debugPrint("❌ Error fetching from Firestore: $e");
      }
    } else {
      debugPrint("❌ No data in route parameters and no LPM, skipping load");
    }
  }

  Future<void> fetchClientData() async {
    try {
      final query = await FirebaseFirestore.instance.collection('customers').get();

      final Map<String, String> addresses = {};
      final List<String> names = [];

      for (final doc in query.docs) {
        final data = doc.data();
        final partyName = data['Party Names']?.toString() ?? '';
        final address = data['Address']?.toString() ?? '';

        if (partyName.isNotEmpty) {
          names.add(partyName);
          addresses[partyName] = address;
        }
      }

      names.sort();

      setState(() {
        userNames = names;
        clientAddresses = addresses;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("❌ Error fetching customers: $e");
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
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 22),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text(
          "Add Designer Job",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: DesignerStepHeader(currentStep: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Party Name ──────────────────────────────────────────────────
            _fieldCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel("Party Name *"),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SearchableDropdownWithInitial(
                    label: "",
                    items: userNames,
                    initialValue: form.PartyName.text.isEmpty
                        ? null
                        : form.PartyName.text,
                    onChanged: (v) {
                      setState(() {
                        form.PartyName.text = (v ?? "").trim();
                        final address =
                            clientAddresses[v?.trim() ?? ''] ?? '';
                        if (address.isNotEmpty) {
                          form.DeliveryAt.text = address;
                        }
                      });
                    },
                  ),
                ],
              ),
            ),

            // ── Job Name ────────────────────────────────────────────────────
            _fieldCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel("Job Name"),
                  TextInput(
                    label: "",
                    hint: "Enter job name",
                    controller: form.ParticularJobName,
                  ),
                ],
              ),
            ),

            // ── Priority ────────────────────────────────────────────────────
            if (form.canView("Priority"))
              _fieldCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel("Priority"),
                    PrioritySelector(
                      initialValue: form.Priority.text,
                      onChanged: (v) {
                        form.Priority.text = v ?? "";
                      },
                    ),
                  ],
                ),
              ),

            // ── Remark ──────────────────────────────────────────────────────
            if (form.canView("Remark"))
              _fieldCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel("Remark"),
                    TextInput(
                      label: "",
                      hint: "Add a remark",
                      controller: form.Remark,
                    ),
                  ],
                ),
              ),

            // ── Delivery At ─────────────────────────────────────────────────
            _fieldCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel("Delivery At"),
                  TextInput(
                    controller: form.DeliveryAt,
                    label: "",
                    hint: "Address",
                  ),
                ],
              ),
            ),

            // ── Order By ────────────────────────────────────────────────────
            _fieldCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel("Order By"),
                  TextInput(
                    controller: form.OrderBy,
                    label: "",
                    hint: "Name",
                  ),
                ],
              ),
            ),

            // ── LPM ─────────────────────────────────────────────────────────
            _fieldCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel("LPM Number"),
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
                ],
              ),
            ),
          ],
        ),
      ),

      // ── Bottom Navigation ──────────────────────────────────────────────────
      bottomNavigationBar: _DesignerBottomNav(
        showPrev: false,
        showNext: true,
        onNext: () => context.push('/jobform/designer-2'),
      ),
    );
  }
}

// ─── Shared Bottom Nav ────────────────────────────────────────────────────────

class _DesignerBottomNav extends StatelessWidget {
  final bool showPrev;
  final bool showNext;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final Widget? customAction; // for submit button

  const _DesignerBottomNav({
    this.showPrev = true,
    this.showNext = true,
    this.onPrev,
    this.onNext,
    this.customAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (showPrev) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: onPrev,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFFF8D94B), width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Prev",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          if (customAction != null) Expanded(child: customAction!),
        ],
      ),
    );
  }
}