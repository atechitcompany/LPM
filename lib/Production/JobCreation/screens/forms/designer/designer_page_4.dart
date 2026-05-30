import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../new_form_scope.dart';
import '../new_form.dart';
import 'package:lightatech/FormComponents/AddableSearchDropdown.dart';
import 'package:lightatech/FormComponents/FlexibleToggle.dart';
import 'package:lightatech/FormComponents/TextInput.dart';
import 'package:lightatech/core/session/session_manager.dart';
import 'package:lightatech/FormComponents/FileUploadBox.dart';
import 'package:lightatech/FormComponents/SearchableDropdownWithInitial.dart';
import 'dart:convert';

import 'designer_page_1.dart';
import 'designer_widgets.dart';

import 'package:lightatech/services/designer_email_template.dart';
import 'package:http/http.dart' as http;

class DesignerPage4 extends StatefulWidget {
  const DesignerPage4({super.key});

  @override
  State<DesignerPage4> createState() => _DesignerPage4State();
}

class _DesignerPage4State extends State<DesignerPage4> {
  bool isSubmitting = false;
  bool _initialized = false;

  List<String> _strippingItems = ["No"];
  bool _loadingStrippings = true;

  // ── Extra edit-mode-only controllers ────────────────────────────────────
  final _machineName = TextEditingController();
  final _plywoodSizeGriper = TextEditingController();
  final _cuttingRule = TextEditingController();
  final _creasingRule = TextEditingController();
  final _materialToPunch = TextEditingController();
  final _flute = TextEditingController();
  final _boardCompressedThickness = TextEditingController();
  final _centerNotch = TextEditingController();
  final _plywoodThickness = TextEditingController();
  final _partinex = TextEditingController();
  final _nicking = TextEditingController();
  final _broaching = TextEditingController();
  final _bladeWelding = TextEditingController();
  final _strippingMaleFemale = TextEditingController();
  final _sanwitchDie = TextEditingController();
  String? _rubberOrWithout;

  static const _rubberOptions = ['With Rubber', 'Without Rubber'];

  @override
  void initState() {
    super.initState();
    _fetchStrippings();
  }

  @override
  void dispose() {
    _machineName.dispose();
    _plywoodSizeGriper.dispose();
    _cuttingRule.dispose();
    _creasingRule.dispose();
    _materialToPunch.dispose();
    _flute.dispose();
    _boardCompressedThickness.dispose();
    _centerNotch.dispose();
    _plywoodThickness.dispose();
    _partinex.dispose();
    _nicking.dispose();
    _broaching.dispose();
    _bladeWelding.dispose();
    _strippingMaleFemale.dispose();
    _sanwitchDie.dispose();
    super.dispose();
  }

  Future<void> _fetchStrippings() async {
    try {
      final snap = await FirebaseFirestore.instance.collection("Strippings").get();
      final items = snap.docs
          .map((doc) => (doc.data()['Strippings'] ?? '').toString())
          .where((val) => val.isNotEmpty)
          .toList();
      setState(() {
        _strippingItems = ["No", ...items];
        _loadingStrippings = false;
      });
    } catch (e) {
      debugPrint("❌ Error fetching Strippings: $e");
      setState(() => _loadingStrippings = false);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;
    if (NewFormScope.of(context).mode == "edit") _loadDesignerData();
  }

  Future<void> _loadDesignerData() async {
    final form = NewFormScope.of(context);
    final uri = GoRouterState.of(context).uri;
    final dataJson = uri.queryParameters['data'];
    final lpmParam = uri.queryParameters['lpm'];

    if (dataJson != null && dataJson.isNotEmpty) {
      try {
        final decodedData = jsonDecode(dataJson) as Map<String, dynamic>;
        form.StrippingType.text = decodedData["StrippingType"] ?? "No";
        form.LaserCuttingStatus.text = decodedData["LaserCuttingStatus"] ?? "Pending";
        form.RubberFixingDone.text = decodedData["RubberFixingDone"] ?? "No";
        form.WhiteProfileRubber.text = decodedData["WhiteProfileRubber"] ?? "No";
        form.DesigningStatus.text = decodedData["DesigningStatus"] ?? "Pending";
        form.DesignedBy.text = decodedData["DesignedBy"] ?? "";
        form.DesignerCreatedBy.text = decodedData["DesignerCreatedBy"] ?? "";
        // extra fields
        setState(() {
          _machineName.text = decodedData["MachineName"] ?? "";
          _plywoodSizeGriper.text = decodedData["PlywoodSizeGriper"] ?? "";
          _cuttingRule.text = decodedData["CuttingRule"] ?? "";
          _creasingRule.text = decodedData["CreasingRule"] ?? "";
          _materialToPunch.text = decodedData["MaterialToPunch"] ?? "";
          _flute.text = decodedData["Flute"] ?? "";
          _boardCompressedThickness.text = decodedData["BoardCompressedThickness"] ?? "";
          _centerNotch.text = decodedData["CenterNotch"] ?? "";
          _plywoodThickness.text = decodedData["PlywoodThickness"] ?? "";
          _partinex.text = decodedData["Partinex"] ?? "";
          _nicking.text = decodedData["Nicking"] ?? "";
          _broaching.text = decodedData["Broaching"] ?? "";
          _bladeWelding.text = decodedData["BladeWelding"] ?? "";
          _strippingMaleFemale.text = decodedData["StrippingMaleFemale"] ?? "";
          _sanwitchDie.text = decodedData["SanwitchDie"] ?? "";
          final rawRubber = decodedData["RubberOrWithout"]?.toString() ?? "";
          _rubberOrWithout = _rubberOptions.firstWhere(
                (o) => o.toLowerCase() == rawRubber.toLowerCase(),
            orElse: () => '',
          );
          if (_rubberOrWithout!.isEmpty) _rubberOrWithout = null;
        });
      } catch (e) {
        debugPrint("❌ Error decoding data: $e");
      }
    }  else if (lpmParam != null && lpmParam.isNotEmpty) {
  try {
  // Normalize: job doc is always the main ID (before last dash if sub-order appended)
  final mainJobId = lpmParam.contains('-')
  ? lpmParam.split('-').take(4).join('-')
      : lpmParam;

  debugPrint("🔍 Fetching job doc: $mainJobId (from lpmParam: $lpmParam)");

  final snap = await FirebaseFirestore.instance
      .collection("jobs")
      .doc(mainJobId)
      .get();

  debugPrint("📄 Job doc exists: ${snap.exists}");
  debugPrint("📄 Job doc data keys: ${snap.data()?.keys.toList()}");

  if (snap.exists) {
  final designerData =
  Map<String, dynamic>.from(snap.data()?["designer"]?["data"] ?? {});

  debugPrint("🎨 Designer data keys: ${designerData.keys.toList()}");
  debugPrint("🔧 MachineName = ${designerData["MachineName"]}");
  debugPrint("🔧 CuttingRule = ${designerData["CuttingRule"]}");

  setState(() {
  form.StrippingType.text = designerData["StrippingType"] ?? "No";
  form.LaserCuttingStatus.text = designerData["LaserCuttingStatus"] ?? "Pending";
  form.RubberFixingDone.text = designerData["RubberFixingDone"] ?? "No";
  form.WhiteProfileRubber.text = designerData["WhiteProfileRubber"] ?? "No";
  form.DesigningStatus.text = designerData["DesigningStatus"] ?? "Pending";
  form.DesignedBy.text = designerData["DesignedBy"] ?? "";
  form.DesignerCreatedBy.text = designerData["DesignerCreatedBy"] ?? "";

  _machineName.text = designerData["MachineName"] ?? "";
  _plywoodSizeGriper.text = designerData["PlywoodSizeGriper"] ?? "";
  _cuttingRule.text = designerData["CuttingRule"] ?? "";
  _creasingRule.text = designerData["CreasingRule"] ?? "";
  _materialToPunch.text = designerData["MaterialToPunch"] ?? "";
  _flute.text = designerData["Flute"] ?? "";
  _boardCompressedThickness.text = designerData["BoardCompressedThickness"] ?? "";
  _centerNotch.text = designerData["CenterNotch"] ?? "";
  _plywoodThickness.text = designerData["PlywoodThickness"] ?? "";
  _partinex.text = designerData["Partinex"] ?? "";
  _nicking.text = designerData["Nicking"] ?? "";
  _broaching.text = designerData["Broaching"] ?? "";
  _bladeWelding.text = designerData["BladeWelding"] ?? "";
  _strippingMaleFemale.text = designerData["StrippingMaleFemale"] ?? "";
  _sanwitchDie.text = designerData["SanwitchDie"] ?? "";

  final rawRubber = designerData["RubberOrWithout"]?.toString() ?? "";
  _rubberOrWithout = _rubberOptions.firstWhere(
  (o) => o.toLowerCase() == rawRubber.toLowerCase(),
  orElse: () => '',
  );
  if (_rubberOrWithout!.isEmpty) _rubberOrWithout = null;
  });
  } else {
  debugPrint("❌ Job doc not found at: $mainJobId");
  }
  } catch (e) {
  debugPrint("❌ Error fetching from Firestore: $e");
  }
  }
  }

  Future<String> _getCurrentUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userName = prefs.getString('userName');
      if (userName != null && userName.isNotEmpty && userName != 'User') return userName;

      String? email = SessionManager.getEmail();
      if (email != null && email.isNotEmpty) {
        final qs = await FirebaseFirestore.instance
            .collection("Staff")
            .where("Email", isEqualTo: email)
            .limit(1)
            .get();
        if (qs.docs.isNotEmpty) {
          userName = qs.docs.first.data()["Name"];
          if (userName != null && userName.isNotEmpty) return userName;
        }
      }

      email = prefs.getString('userEmail');
      if (email != null && email.isNotEmpty) {
        final qs = await FirebaseFirestore.instance
            .collection("Staff")
            .where("Email", isEqualTo: email)
            .limit(1)
            .get();
        if (qs.docs.isNotEmpty) {
          userName = qs.docs.first.data()["Name"];
          if (userName != null && userName.isNotEmpty) return userName;
        }
      }
      return "Unknown";
    } catch (e) {
      debugPrint("❌ Error getting current user name: $e");
      return "Unknown";
    }
  }

  Future<void> _submitAsQuotation(NewFormState form) async {
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final year = (now.year % 100).toString().padLeft(2, '0');
    final counterRef = FirebaseFirestore.instance
        .collection("counters")
        .doc("QUOTE_${now.year}_$month");

    String quoteNumber = "";
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snap = await transaction.get(counterRef);
      int lastNo = snap.exists ? (snap.data()?["lastNo"] ?? 0) : 0;
      final newNo = lastNo + 1;
      transaction.set(counterRef, {"lastNo": newNo}, SetOptions(merge: true));
      quoteNumber = "QUOTE-${newNo.toString().padLeft(5, '0')}-$month-$year-01";
    });

    final data = form.buildFormData();
    await FirebaseFirestore.instance.collection("quotations").doc(quoteNumber).set({
      "quoteNumber": quoteNumber,
      "partyName": form.PartyName.text,
      "createdAt": FieldValue.serverTimestamp(),
      "status": "pending",
      "designer": {
        "submitted": true,
        "submittedAt": FieldValue.serverTimestamp(),
        "submittedBy": form.DesignerCreatedBy.text.isNotEmpty
            ? form.DesignerCreatedBy.text
            : "Unknown",
        "data": data,
      },
    });
    debugPrint("✅ Quotation saved as $quoteNumber");
  }

  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);
    final bool isEditMode = form.mode == "edit";
    final approvalStatus = form.SendApproval.text;
    final lpmParam = form.LpmAutoIncrement.text;
    final bool isDesigningDone =
        form.DesigningStatus.text.trim().toLowerCase() == "done";
    final bool laserDone =
        form.LaserCuttingStatus.text.trim().toLowerCase() == "done";
    final bool rubberFixingDone =
        form.RubberFixingDone.text.trim().toLowerCase() == "yes";
    final bool whiteProfileRubber =
        form.WhiteProfileRubber.text.trim().toLowerCase() == "yes";
    final mainJobId = lpmParam.contains('-')
        ? lpmParam.split('-').take(4).join('-')
        : lpmParam;

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
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.black),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(56),
          child: DesignerStepHeader(currentStep: 4),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Generate LPM (non-edit only) ─────────────────────────────
            if (!isEditMode)
              fieldCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionLabel("Generate LPM NUMBER"),
                    FlexibleToggle(
                      label: "",
                      inactiveText: "No",
                      activeText: "Yes",
                      initialValue: form.generateLpmToggle.text == "YES",
                      onChanged: (val) async {
                        await form.handleLpmToggle(val);
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),

            // ── Rubber Fixing Done ────────────────────────────────────────
            if (form.canView("RubberFixingDone"))
              fieldCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionLabel("Rubber Fixing Done"),
                    FlexibleToggle(
                      label: "",
                      inactiveText: "No",
                      activeText: "Yes",
                      initialValue: rubberFixingDone,
                      onChanged: (val) =>
                          setState(() => form.RubberFixingDone.text = val ? "Yes" : "No"),
                    ),
                  ],
                ),
              ),

            // ── White Profile Rubber ──────────────────────────────────────
            if (form.canView("WhiteProfileRubber"))
              fieldCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionLabel("White Profile Rubber"),
                    FlexibleToggle(
                      label: "",
                      inactiveText: "No",
                      activeText: "Yes",
                      initialValue: whiteProfileRubber,
                      onChanged: (val) =>
                          setState(() => form.WhiteProfileRubber.text = val ? "Yes" : "No"),
                    ),
                  ],
                ),
              ),

            // ── Drawing Attachment ────────────────────────────────────────
            if (form.canView("DrawingAttachment"))
              fieldCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionLabel("Drawing Attachment"),
                    FileUploadBox(
                      jobId: mainJobId,
                      fieldName: 'DrawingAttachment',
                      onFileSelected: (file) => debugPrint("Drawing: ${file.name}"),
                    ),
                  ],
                ),
              ),

            // ── Rubber Report (only when designing done) ──────────────────
            if (isDesigningDone && form.canView("RubberReport"))
              fieldCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionLabel("Rubber Report"),
                    FileUploadBox(
                      jobId: mainJobId,
                      fieldName: 'RubberReport',
                      onFileSelected: (file) => debugPrint("Rubber: ${file.name}"),
                    ),
                  ],
                ),
              ),

            // ── Punch Report ──────────────────────────────────────────────
            if (form.canView("PunchReport"))
              fieldCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionLabel("Punch Report"),
                    FileUploadBox(
                      jobId: mainJobId,
                      fieldName: 'PunchReport',
                      onFileSelected: (file) => debugPrint("Punch: ${file.name}"),
                    ),
                  ],
                ),
              ),

            // ── Designing Status ──────────────────────────────────────────
            if (form.canView("DesigningStatus"))
              fieldCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionLabel("Designing Status"),
                    FlexibleToggle(
                      label: "",
                      inactiveText: "Pending",
                      activeText: "Done",
                      initialValue: isDesigningDone,
                      onChanged: (val) async {
                        setState(() => form.DesigningStatus.text = val ? "Done" : "Pending");
                        if (val) {
                          final userName = await _getCurrentUserName();
                          if (mounted) {
                            setState(() {
                              form.DesignedBy.text = userName;
                              form.DesignedByTimestamp.text = DateTime.now().toString();
                            });
                          }
                        } else {
                          form.DesignedBy.clear();
                          form.DesignedByTimestamp.clear();
                        }
                      },
                    ),
                    if (isDesigningDone) ...[
                      const SizedBox(height: 14),
                      TextField(
                        controller: form.DesignedBy,
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: "Designed By",
                          labelStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        style: const TextStyle(color: Colors.black87, fontSize: 13),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: form.DesignedByTimestamp,
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: "Designed At",
                          labelStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        style: const TextStyle(color: Colors.black87, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),

            // ── Edit-mode-only extra fields ───────────────────────────────
            if (isEditMode) ...[
              fieldCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  sectionLabel("Machine Name"),
                  TextInput(label: "", hint: "Machine name", controller: _machineName),
                ]),
              ),
              fieldCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  sectionLabel("Ply Wood Size & Griper"),
                  TextInput(label: "", hint: "e.g. 30x40, Griper 5mm", controller: _plywoodSizeGriper),
                ]),
              ),
              fieldCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  sectionLabel("Rubber Or Without Rubber"),
                  SearchableDropdownWithInitial(
                    label: "",
                    items: _rubberOptions,
                    initialValue: _rubberOrWithout,
                    onChanged: (v) => setState(() => _rubberOrWithout = v),
                  ),
                ]),
              ),
              fieldCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  sectionLabel("Cutting Rule"),
                  TextInput(label: "", hint: "Cutting rule details", controller: _cuttingRule),
                ]),
              ),
              fieldCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  sectionLabel("Creasing Rule"),
                  TextInput(label: "", hint: "Creasing rule details", controller: _creasingRule),
                ]),
              ),
              fieldCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  sectionLabel("Material To Punch"),
                  TextInput(label: "", hint: "Material description", controller: _materialToPunch),
                ]),
              ),
              fieldCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  sectionLabel("Flute"),
                  TextInput(label: "", hint: "Flute type", controller: _flute),
                ]),
              ),
              fieldCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  sectionLabel("Board Compressed Thickness"),
                  TextInput(label: "", hint: "e.g. 4mm", controller: _boardCompressedThickness),
                ]),
              ),
              fieldCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  sectionLabel("Center Notch"),
                  TextInput(label: "", hint: "Center notch details", controller: _centerNotch),
                ]),
              ),
              fieldCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  sectionLabel("Ply Wood Thickness"),
                  TextInput(label: "", hint: "e.g. 18mm", controller: _plywoodThickness),
                ]),
              ),
              fieldCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  sectionLabel("Partinex"),
                  TextInput(label: "", hint: "Partinex details", controller: _partinex),
                ]),
              ),
              fieldCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  sectionLabel("Nicking"),
                  TextInput(label: "", hint: "Nicking details", controller: _nicking),
                ]),
              ),
              fieldCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  sectionLabel("Broaching"),
                  TextInput(label: "", hint: "Broaching details", controller: _broaching),
                ]),
              ),
              fieldCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  sectionLabel("Blade Welding"),
                  TextInput(label: "", hint: "Blade welding details", controller: _bladeWelding),
                ]),
              ),
              fieldCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  sectionLabel("Stripping Male & Female"),
                  TextInput(label: "", hint: "Stripping details", controller: _strippingMaleFemale),
                ]),
              ),
              fieldCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  sectionLabel("Sanwitch Die"),
                  TextInput(label: "", hint: "Sanwitch die details", controller: _sanwitchDie),
                ]),
              ),
            ],

            // ── Quotation ─────────────────────────────────────────────────
            fieldCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  sectionLabel("Quotation"),
                  FlexibleToggle(
                    label: "",
                    inactiveText: "No Quotation",
                    activeText: "Yes Quotation",
                    initialValue: form.QuotationStatus.text.trim().toLowerCase() == "yes",
                    onChanged: (val) =>
                        setState(() => form.QuotationStatus.text = val ? "Yes" : "No"),
                  ),
                ],
              ),
            ),

            // ── Send Approval ─────────────────────────────────────────────
            if (form.canView("SendApproval") && approvalStatus != "changes")
              fieldCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionLabel("Send Approval"),
                    SearchableDropdownWithInitial(
                      label: "",
                      items: const ["YES", "NO"],
                      initialValue: form.SendApproval.text.isEmpty ? null : form.SendApproval.text,
                      onChanged: (v) =>
                          setState(() => form.SendApproval.text = (v ?? "").trim()),
                    ),
                  ],
                ),
              ),

            // ── Submit Button ─────────────────────────────────────────────
            if (form.canView("submitButton")) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                    setState(() => isSubmitting = true);
                    try {
                      final isQuotation =
                          form.QuotationStatus.text.trim().toLowerCase() == "yes";
                      final sendApproval = form.SendApproval.text.trim().toUpperCase();

                      if (isQuotation && sendApproval != "YES") {
                        await _submitAsQuotation(form);
                      } else {
                        await form.submitDesignerForm();
                      }

                      // ── Email notification ────────────────────────
                      try {
                        if (form.DesigningStatus.text.trim().toLowerCase() == 'done') {
                          final partyName = form.PartyName.text.trim();
                          if (partyName.isNotEmpty) {
                            final clientSnap = await FirebaseFirestore.instance
                                .collection('customers')
                                .where('Party Names', isEqualTo: partyName)
                                .limit(1)
                                .get();
                            if (clientSnap.docs.isNotEmpty) {
                              final clientEmail = (clientSnap.docs.first
                                  .data()['Email'] ??
                                  '')
                                  .toString()
                                  .trim();
                              if (clientEmail.isNotEmpty) {
                                final emailLpm = form.LpmAutoIncrement.text.trim();
                                final emailMainJobId = emailLpm.contains('-')
                                    ? emailLpm.split('-').take(4).join('-')
                                    : emailLpm;
                                String? designFileUrl;
                                try {
                                  final jobDoc = await FirebaseFirestore.instance
                                      .collection('jobs')
                                      .doc(emailMainJobId)
                                      .get();
                                  designFileUrl = jobDoc.data()?['files']
                                  ?['DrawingAttachment']?['viewUrl']
                                      ?.toString();
                                } catch (_) {}

                                final htmlBody = generateDesignerEmailHtml(
                                  partyName: partyName,
                                  productName: form.ParticularJobName.text,
                                  lpmNumber: emailLpm,
                                  orderDate: DateTime.now()
                                      .toString()
                                      .split('.')
                                      .first,
                                  designedBy: form.DesignedBy.text,
                                  designedByTimestamp:
                                  form.DesignedByTimestamp.text,
                                  designFileUrl: designFileUrl,
                                );

                                final response = await http.post(
                                  Uri.parse(
                                      'https://senddispatchemail-3vvqs62r6q-uc.a.run.app'),
                                  headers: {'Content-Type': 'application/json'},
                                  body: jsonEncode({
                                    'to': clientEmail,
                                    'subject': 'Your Design is Ready! — $emailLpm',
                                    'htmlBody': htmlBody,
                                  }),
                                );
                                debugPrint(response.statusCode == 200
                                    ? '✅ Email sent to $clientEmail'
                                    : '⚠️ Email failed: ${response.statusCode}');
                              }
                            }
                          }
                        }
                      } catch (e) {
                        debugPrint('⚠️ Email notification failed (non-blocking): $e');
                      }

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("✅ Submitted Successfully"),
                            backgroundColor: Colors.green,
                          ),
                        );
                        context.go('/dashboard');
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("❌ Error: $e"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } finally {
                      if (mounted) setState(() => isSubmitting = false);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF8D94B),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                  )
                      : const Text(
                    "Submit",
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
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

class _DesignerBottomNavWithSubmit extends StatelessWidget {
  final VoidCallback onPrev;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  const _DesignerBottomNavWithSubmit({
    required this.onPrev,
    required this.isSubmitting,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onPrev,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Color(0xFFF8D94B), width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Prev",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 15)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: isSubmitting ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF8D94B),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isSubmitting
                  ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : const Text("Submit",
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}