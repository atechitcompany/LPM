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

// Import shared widgets from page1
import 'designer_page_1.dart';
import 'designer_widgets.dart';

// --- BEGIN AUTOMATED CLIENT EMAIL NOTIFICATION ---
import 'package:lightatech/services/designer_email_template.dart';
import 'package:http/http.dart' as http;
// --- END AUTOMATED CLIENT EMAIL NOTIFICATION ---

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

  @override
  void initState() {
    super.initState();
    _fetchStrippings();
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
      } catch (e) {
        debugPrint("❌ Error decoding data: $e");
      }
    } else if (lpmParam != null && lpmParam.isNotEmpty) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection("jobs")
            .doc(lpmParam)
            .get();
        if (snap.exists) {
          final decodedData =
          Map<String, dynamic>.from(snap.data()?["designer"]?["data"] ?? {});
          setState(() {
            form.StrippingType.text = decodedData["StrippingType"] ?? "No";
            form.LaserCuttingStatus.text = decodedData["LaserCuttingStatus"] ?? "Pending";
            form.RubberFixingDone.text = decodedData["RubberFixingDone"] ?? "No";
            form.WhiteProfileRubber.text = decodedData["WhiteProfileRubber"] ?? "No";
            form.DesigningStatus.text = decodedData["DesigningStatus"] ?? "Pending";
            form.DesignedBy.text = decodedData["DesignedBy"] ?? "";
            form.DesignerCreatedBy.text = decodedData["DesignerCreatedBy"] ?? "";
          });
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

      if (userName != null && userName.isNotEmpty && userName != 'User') {
        debugPrint("✅ Got user name from SharedPreferences: $userName");
        return userName;
      }

      String? email = SessionManager.getEmail();
      if (email != null && email.isNotEmpty) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection("Staff")
            .where("Email", isEqualTo: email)
            .limit(1)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          userName = querySnapshot.docs.first.data()["Name"];
          if (userName != null && userName.isNotEmpty) {
            debugPrint("✅ Got user name from Staff: $userName");
            return userName;
          }
        }
      }

      email = prefs.getString('userEmail');
      if (email != null && email.isNotEmpty) {
        final querySnapshot = await FirebaseFirestore.instance
            .collection("Staff")
            .where("Email", isEqualTo: email)
            .limit(1)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          userName = querySnapshot.docs.first.data()["Name"];
          if (userName != null && userName.isNotEmpty) {
            debugPrint("✅ Got user name from Staff (via userEmail): $userName");
            return userName;
          }
        }
      }

      debugPrint("⚠️ Could not find user name, returning 'Unknown'");
      return "Unknown";
    } catch (e) {
      debugPrint("❌ Error getting current user name: $e");
      return "Unknown";
    }
  }
  Future<void> _submitAsQuotation(NewFormState form) async {
    // Generate QUOTE number
    final now = DateTime.now();
    final month = now.month.toString().padLeft(2, '0');
    final year = (now.year % 100).toString().padLeft(2, '0');
    final counterDocId = "QUOTE_${now.year}_$month";

    final counterRef = FirebaseFirestore.instance
        .collection("counters")
        .doc(counterDocId);

    String quoteNumber = "";

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snap = await transaction.get(counterRef);
      int lastNo = snap.exists ? (snap.data()?["lastNo"] ?? 0) : 0;
      final newNo = lastNo + 1;
      transaction.set(counterRef, {"lastNo": newNo}, SetOptions(merge: true));
      quoteNumber = "QUOTE-${newNo.toString().padLeft(5, '0')}-$month-$year-01";
    });

    final data = form.buildFormData();

    await FirebaseFirestore.instance
        .collection("quotation_pending")
        .doc(quoteNumber)
        .set({
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
    // NOTE: LPM counter is NOT incremented here
  }

  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);
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
            // --- BEGIN ALTERNATIVE LPM TOGGLE FEATURE ---
            if (NewFormScope.of(context).mode != "edit")
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
            // --- END ALTERNATIVE LPM TOGGLE FEATURE ---
            // ── Rubber Fixing Done ───────────────────────────────────────────
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
                      onChanged: (val) => setState(
                              () => form.RubberFixingDone.text = val ? "Yes" : "No"),
                    ),
                  ],
                ),
              ),

            // ── White Profile Rubber ─────────────────────────────────────────
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
                      onChanged: (val) => setState(
                              () => form.WhiteProfileRubber.text = val ? "Yes" : "No"),
                    ),
                  ],
                ),
              ),

            // ── Drawing Attachment ───────────────────────────────────────────
            if (form.canView("DrawingAttachment"))
              fieldCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionLabel("Drawing Attachment"),
                    FileUploadBox(
                      jobId: mainJobId,
                      fieldName: 'DrawingAttachment',
                      onFileSelected: (file) {
                        debugPrint("Drawing: ${file.name}");
                      },
                    ),
                  ],
                ),
              ),

            // ── Rubber Report ────────────────────────────────────────────────
            if (isDesigningDone && form.canView("RubberReport"))
              fieldCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionLabel("Rubber Report"),
                    FileUploadBox(
                      jobId: mainJobId,
                      fieldName: 'RubberReport',
                      onFileSelected: (file) {
                        debugPrint("Rubber: ${file.name}");
                      },
                    ),
                  ],
                ),
              ),

            // ── Punch Report ─────────────────────────────────────────────────
            if (form.canView("PunchReport"))
              fieldCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionLabel("Punch Report"),
                    FileUploadBox(
                      jobId: mainJobId,
                      fieldName: 'PunchReport',
                      onFileSelected: (file) {
                        debugPrint("Punch: ${file.name}");
                      },
                    ),
                  ],
                ),
              ),

            // ── Designing Status ─────────────────────────────────────────────
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
                        setState(() {
                          form.DesigningStatus.text = val ? "Done" : "Pending";
                        });
                        if (val) {
                          final userName = await _getCurrentUserName();
                          if (mounted) {
                            setState(() {
                              form.DesignedBy.text = userName;
                              form.DesignedByTimestamp.text =
                                  DateTime.now().toString();
                            });
                          }
                        } else {
                          form.DesignedBy.clear();
                          form.DesignedByTimestamp.clear();
                        }
                      },
                    ),

                    // Designed By / At (visible when done)
                    if (isDesigningDone) ...[
                      const SizedBox(height: 14),
                      TextField(
                        controller: form.DesignedBy,
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: "Designed By",
                          labelStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        style: const TextStyle(
                            color: Colors.black87, fontSize: 13),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: form.DesignedByTimestamp,
                        enabled: false,
                        decoration: InputDecoration(
                          labelText: "Designed At",
                          labelStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        style: const TextStyle(
                            color: Colors.black87, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            // ── Quotation ────────────────────────────────────────────
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
                    onChanged: (val) => setState(
                          () => form.QuotationStatus.text = val ? "Yes" : "No",
                    ),
                  ),
                ],
              ),
            ),
            // ── Send Approval ────────────────────────────────────────────────
            if (form.canView("SendApproval") && approvalStatus != "changes")
              fieldCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    sectionLabel("Send Approval"),
                    SearchableDropdownWithInitial(
                      label: "",
                      items: const ["YES", "NO"],
                      initialValue: form.SendApproval.text.isEmpty
                          ? null
                          : form.SendApproval.text,
                      onChanged: (v) => setState(
                              () => form.SendApproval.text = (v ?? "").trim()),
                    ),
                  ],
                ),
              ),
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
                      final sendApproval =
                      form.SendApproval.text.trim().toUpperCase();

                      if (isQuotation && sendApproval != "YES") {
                        await _submitAsQuotation(form);
                      } else {
                        await form.submitDesignerForm();
                      }

                      // --- BEGIN AUTOMATED CLIENT EMAIL NOTIFICATION ---
                      // --- BEGIN DESIGNER EMAIL PAYLOAD ---
                      try {
                        if (form.DesigningStatus.text.trim().toLowerCase() == 'done') {
                          final partyName = form.PartyName.text.trim();
                          if (partyName.isNotEmpty) {
                            // Optimized Firestore query: WHERE + LIMIT(1)
                            final clientSnap = await FirebaseFirestore.instance
                                .collection('customers')
                                .where('Party Names', isEqualTo: partyName)
                                .limit(1)
                                .get();

                            if (clientSnap.docs.isNotEmpty) {
                              final clientEmail = (clientSnap.docs.first.data()['Email'] ?? '').toString().trim();
                              if (clientEmail.isNotEmpty) {
                                // Fetch design file URL from job document
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
                                  designFileUrl = jobDoc.data()?['files']?['DrawingAttachment']?['viewUrl']?.toString();
                                } catch (_) {}

                                // Generate HTML email
                                final htmlBody = generateDesignerEmailHtml(
                                  partyName: partyName,
                                  productName: form.ParticularJobName.text,
                                  lpmNumber: emailLpm,
                                  orderDate: DateTime.now().toString().split('.').first,
                                  designedBy: form.DesignedBy.text,
                                  designedByTimestamp: form.DesignedByTimestamp.text,
                                  designFileUrl: designFileUrl,
                                );

                                // Call the sendDispatchEmail Cloud Function via HTTP POST
                                final response = await http.post(
                                  Uri.parse('https://senddispatchemail-3vvqs62r6q-uc.a.run.app'),
                                  headers: {'Content-Type': 'application/json'},
                                  body: jsonEncode({
                                    'to': clientEmail,
                                    'subject': 'Your Design is Ready! — $emailLpm',
                                    'htmlBody': htmlBody,
                                  }),
                                );
                                
                                if (response.statusCode == 200) {
                                  debugPrint('✅ sendDispatchEmail called successfully for $clientEmail');
                                } else {
                                  debugPrint('⚠️ sendDispatchEmail failed with status ${response.statusCode}: ${response.body}');
                                }
                              } else {
                                debugPrint('⚠️ Client email is empty for party: $partyName');
                              }
                            } else {
                              debugPrint('⚠️ No customer found matching party name: $partyName');
                            }
                          }
                        }
                      } catch (e) {
                        debugPrint('⚠️ Email notification failed (non-blocking): $e');
                      }
                      // --- END DESIGNER EMAIL PAYLOAD ---
                      // --- END AUTOMATED CLIENT EMAIL NOTIFICATION ---

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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                      : const Text(
                    "Submit",
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),

      // ── Bottom Nav with Submit ────────────────────────────────────────────

    );
  }
}

// ─── Special bottom nav for page 4 (Prev + Submit) ───────────────────────────

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
          Expanded(
            child: ElevatedButton(
              onPressed: isSubmitting ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF8D94B),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isSubmitting
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
                  : const Text(
                "Submit",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}