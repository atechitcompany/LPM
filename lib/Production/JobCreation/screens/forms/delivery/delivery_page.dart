import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lightatech/FormComponents/TextInput.dart';
import 'package:lightatech/FormComponents/FlexibleToggle.dart';
import 'package:lightatech/FormComponents/FileUploadBox.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lightatech/services/department_email_template.dart';
import '../new_form_scope.dart';

class DeliveryPage extends StatefulWidget {
  const DeliveryPage({super.key});

  @override
  State<DeliveryPage> createState() => _DeliveryPageState();
}

class _DeliveryPageState extends State<DeliveryPage> {
  bool loading = true;
  bool _loaded = false;

  final _contactNumber = TextEditingController();
  final _whatsappNumber = TextEditingController();
  final _clientAddress = TextEditingController();
  final _receiverName = TextEditingController();
  final _deliveryAddress = TextEditingController();
  final _courierName = TextEditingController();
  final _deliveryRemark = TextEditingController();

  @override
  void dispose() {
    _contactNumber.dispose();
    _whatsappNumber.dispose();
    _clientAddress.dispose();
    _receiverName.dispose();
    _deliveryAddress.dispose();
    _courierName.dispose();
    _deliveryRemark.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final form = NewFormScope.of(context);
    final uri = GoRouterState.of(context).uri;
    String? lpmParam = uri.queryParameters['lpm'];
    final lpm = (lpmParam != null && lpmParam.isNotEmpty) ? lpmParam : form.LpmAutoIncrement.text;

    if (lpm.isEmpty) { 
      setState(() => loading = false); 
      return; 
    }

    try {
      final snap = await FirebaseFirestore.instance.collection("jobs").doc(lpm).get();
      if (!snap.exists) { setState(() => loading = false); return; }

      final data = snap.data()!;
      final designer = Map<String, dynamic>.from(data["designer"]?["data"] ?? {});
      final autoBending = Map<String, dynamic>.from(data["autoBending"]?["data"] ?? {});
      final manualBending = Map<String, dynamic>.from(data["manualBending"]?["data"] ?? {});
      final laserCutting = Map<String, dynamic>.from(data["laserCutting"]?["data"] ?? {});
      final rubber = Map<String, dynamic>.from(data["rubber"]?["data"] ?? {});
      final account = Map<String, dynamic>.from(data["account"]?["data"] ?? {});
      final delivery = Map<String, dynamic>.from(data["delivery"]?["data"] ?? {});

      String getVal(String deptKey, String fieldKey) {
        if (data[deptKey] is Map) {
          final deptMap = data[deptKey] as Map;
          if (deptMap["data"] is Map) {
            final dataMap = deptMap["data"] as Map;
            if (dataMap[fieldKey] != null && dataMap[fieldKey].toString().trim().isNotEmpty) {
              return dataMap[fieldKey].toString();
            }
          }
          if (deptMap[fieldKey] != null && deptMap[fieldKey].toString().trim().isNotEmpty) {
            return deptMap[fieldKey].toString();
          }
        }
        if (data[fieldKey] != null && data[fieldKey].toString().trim().isNotEmpty) {
          return data[fieldKey].toString();
        }
        if (data["designer"] is Map) {
          final desMap = data["designer"] as Map;
          if (desMap["data"] is Map) {
            final desDataMap = desMap["data"] as Map;
            if (desDataMap[fieldKey] != null && desDataMap[fieldKey].toString().trim().isNotEmpty) {
              return desDataMap[fieldKey].toString();
            }
          }
        }
        return "";
      }

      form.PartyName.text = getVal("designer", "PartyName");
      form.ParticularJobName.text = getVal("designer", "ParticularJobName").isNotEmpty 
          ? getVal("designer", "ParticularJobName") 
          : getVal("designer", "particularJobName");
      form.LpmAutoIncrement.text = lpm;
      form.DeliveryAt.text = getVal("designer", "DeliveryAt").isNotEmpty 
          ? getVal("designer", "DeliveryAt") 
          : getVal("account", "DeliveryAt");
      form.Remark.text = getVal("designer", "Remark").isNotEmpty 
          ? getVal("designer", "Remark") 
          : getVal("account", "Remark");
      
      // ✅ Fetch Created By details from other departments
      final designerCreated = getVal("designer", "DesignerCreatedBy").isNotEmpty
          ? getVal("designer", "DesignerCreatedBy")
          : (data["designer"] is Map ? (data["designer"] as Map)["submittedBy"]?.toString() ?? "" : "");
      form.DesignerCreatedBy.text = designerCreated;

      final autoBendingCreated = getVal("autoBending", "AutoBendingCreatedByName").isNotEmpty
          ? getVal("autoBending", "AutoBendingCreatedByName")
          : getVal("autoBending", "AutoBendingCreatedBy");
      form.AutoBendingCreatedBy.text = autoBendingCreated;

      final manualBendingCreated = getVal("manualBending", "ManualBendingCreatedByName").isNotEmpty
          ? getVal("manualBending", "ManualBendingCreatedByName")
          : getVal("manualBending", "ManualBendingCreatedBy");
      form.ManualBendingCreatedBy.text = manualBendingCreated;

      final laserCuttingCreated = getVal("laserCutting", "LaserCuttingCreatedByName").isNotEmpty
          ? getVal("laserCutting", "LaserCuttingCreatedByName")
          : getVal("laserCutting", "LaserCuttingCreatedBy");
      form.LaserCuttingCreatedBy.text = laserCuttingCreated;

      form.RubberCreatedBy.text = getVal("rubber", "RubberCreatedBy").isNotEmpty
          ? getVal("rubber", "RubberCreatedBy")
          : getVal("rubber", "RubberDoneBy");
      form.AccountsCreatedBy.text = getVal("account", "AccountsCreatedBy");

      // ✅ Fetch Client contact/whatsapp details from the 'customers' collection
      final partyNameVal = getVal("designer", "PartyName");
      String clientContact = "";
      String clientWhatsapp = "";
      if (partyNameVal.isNotEmpty) {
        try {
          final clientSnap = await FirebaseFirestore.instance
              .collection('customers')
              .where('Party Names', isEqualTo: partyNameVal)
              .limit(1)
              .get();
          if (clientSnap.docs.isNotEmpty) {
            final clientData = clientSnap.docs.first.data();
            clientContact = clientData['Contact']?.toString() ?? "";
            clientWhatsapp = clientData['Whatsapp Number']?.toString() ?? "";
          }
        } catch (e) {
          debugPrint("⚠️ Error fetching customer contact/whatsapp: $e");
        }
      }

      final deliveryData = data["delivery"] is Map ? data["delivery"] as Map : {};
      final deliverySubData = deliveryData["data"] is Map ? deliveryData["data"] as Map : {};

      form.DeliveryStatus.text = deliverySubData["DeliveryStatus"]?.toString() ?? deliveryData["DeliveryStatus"]?.toString() ?? "Pending";
      form.JobDone.text = deliverySubData["JobDone"]?.toString() ?? deliveryData["JobDone"]?.toString() ?? "NO";

      setState(() {
        final contactVal = deliverySubData["ContactNumber"]?.toString() ?? deliveryData["ContactNumber"]?.toString() ?? "";
        _contactNumber.text = contactVal.trim().isNotEmpty ? contactVal : clientContact;

        final whatsappVal = deliverySubData["WhatsappNumber"]?.toString() ?? deliveryData["WhatsappNumber"]?.toString() ?? "";
        _whatsappNumber.text = whatsappVal.trim().isNotEmpty ? whatsappVal : clientWhatsapp;
        
        final clientAddr = deliverySubData["ClientAddress"]?.toString() ?? deliveryData["ClientAddress"]?.toString() ?? "";
        _clientAddress.text = clientAddr.trim().isNotEmpty ? clientAddr : getVal("designer", "FullAddress");
        
        _receiverName.text = deliverySubData["ReceiverName"]?.toString() ?? deliveryData["ReceiverName"]?.toString() ?? "";
        
        final delAddr = deliverySubData["DeliveryAddress"]?.toString() ?? deliveryData["DeliveryAddress"]?.toString() ?? "";
        _deliveryAddress.text = delAddr.trim().isNotEmpty ? delAddr : getVal("designer", "FullAddress");
        
        _courierName.text = deliverySubData["CourierName"]?.toString() ?? deliveryData["CourierName"]?.toString() ?? "";
        _deliveryRemark.text = deliverySubData["DeliveryRemark"]?.toString() ?? deliveryData["DeliveryRemark"]?.toString() ?? "";
      });
    } catch (e) {
      debugPrint("❌ Error loading delivery data: $e");
    }
    setState(() => loading = false);
  }

  Widget _fieldCard({required Widget child}) => Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
    ),
    child: child,
  );

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
  );

  @override
  Widget build(BuildContext context) {
    final form = NewFormScope.of(context);
    final lpmParam = form.LpmAutoIncrement.text;

    if (loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final bool isDeliveryDone = form.DeliveryStatus.text.toLowerCase() == "done";
    final bool isJobDone = form.JobDone.text.toUpperCase() == "YES";

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text("Delivery", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── View-only fields ──────────────────────────────────────────
            if (form.canView("PartyName"))
              _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label("Party Name"),
                TextInput(label: "", controller: form.PartyName, readOnly: true, hint: ""),
              ])),

            // ── Contact Number ────────────────────────────────────────────
            _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label("Contact Number"),
              TextInput(label: "", controller: _contactNumber, hint: "Enter contact number"),
            ])),

            // ── WhatsApp Number ───────────────────────────────────────────
            _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label("WhatsApp Number"),
              TextInput(label: "", controller: _whatsappNumber, hint: "Enter WhatsApp number"),
            ])),

            if (form.canView("ParticularJobName"))
              _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label("Particular Job Name"),
                TextInput(label: "", controller: form.ParticularJobName, readOnly: true, hint: ""),
              ])),

            if (form.canView("LpmAutoIncrement"))
              _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label("LPM"),
                TextInput(label: "", controller: form.LpmAutoIncrement, readOnly: true, hint: ""),
              ])),

            if (form.canView("Remark"))
              _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label("Remark"),
                TextInput(label: "", controller: form.Remark, readOnly: true, hint: ""),
              ])),

            if (form.canView("DeliveryAt"))
              _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label("Delivery At"),
                TextInput(label: "", controller: form.DeliveryAt, readOnly: true, hint: ""),
              ])),

            if (form.canView("DesignerCreatedBy"))
              _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label("Designer Created By"),
                TextInput(label: "", controller: form.DesignerCreatedBy, readOnly: true, hint: ""),
              ])),

            if (form.canView("AutoBendingCreatedBy"))
              _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label("Auto Bending Created By"),
                TextInput(label: "", controller: form.AutoBendingCreatedBy, readOnly: true, hint: ""),
              ])),

            if (form.canView("ManualBendingCreatedBy"))
              _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label("Manual Bending Created By"),
                TextInput(label: "", controller: form.ManualBendingCreatedBy, readOnly: true, hint: ""),
              ])),

            if (form.canView("LaserCuttingCreatedBy"))
              _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label("Laser Cutting Created By"),
                TextInput(label: "", controller: form.LaserCuttingCreatedBy, readOnly: true, hint: ""),
              ])),

            if (form.canView("RubberCreatedBy"))
              _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label("Rubber Created By"),
                TextInput(label: "", controller: form.RubberCreatedBy, readOnly: true, hint: ""),
              ])),

            if (form.canView("AccountsCreatedBy"))
              _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label("Accounts Created By"),
                TextInput(label: "", controller: form.AccountsCreatedBy, readOnly: true, hint: ""),
              ])),

            // ── Client Address ────────────────────────────────────────────
            _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label("Client Address"),
              TextInput(label: "", controller: _clientAddress, hint: "Enter client address"),
            ])),

            // ── Receiver Name ─────────────────────────────────────────────
            _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label("Receiver Name"),
              TextInput(label: "", controller: _receiverName, hint: "Enter receiver name"),
            ])),

            // ── Delivery Address ──────────────────────────────────────────
            _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label("Delivery Address"),
              TextInput(label: "", controller: _deliveryAddress, hint: "Enter delivery address"),
            ])),

            // ── Courier Name ──────────────────────────────────────────────
            _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label("Courier Name"),
              TextInput(label: "", controller: _courierName, hint: "Enter courier name"),
            ])),

            // ── Remark for Delivery ───────────────────────────────────────
            _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label("Remark for Delivery"),
              TextInput(label: "", controller: _deliveryRemark, hint: "Enter delivery remark"),
            ])),

            // ── Bill Photo / Invoice ──────────────────────────────────────
            _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label("Bill Photo / Invoice (PDF or Image)"),
              // --- BEGIN MULTI-STEP ATTACHMENT STATE FIX ---
              FileUploadBox(
                jobId: lpmParam,
                fieldName: 'BillInvoice',
                initialFileName: form.selectedFiles['BillInvoice'],
                onFileSelected: (file) {
                  setState(() {
                    form.selectedFiles['BillInvoice'] = file.name;
                  });
                  debugPrint("Bill: ${file.name}");
                },
              ),
              // --- END MULTI-STEP ATTACHMENT STATE FIX ---
            ])),

            // ── Product Photo ─────────────────────────────────────────────
            _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _label("Product Photo (Image only)"),
              // --- BEGIN MULTI-STEP ATTACHMENT STATE FIX ---
              FileUploadBox(
                jobId: lpmParam,
                fieldName: 'ProductPhoto',
                initialFileName: form.selectedFiles['ProductPhoto'],
                onFileSelected: (file) {
                  setState(() {
                    form.selectedFiles['ProductPhoto'] = file.name;
                  });
                  debugPrint("Product: ${file.name}");
                },
              ),
              // --- END MULTI-STEP ATTACHMENT STATE FIX ---
            ])),

            // ── Delivery Status ───────────────────────────────────────────
            if (form.canView("DeliveryStatus"))
              _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label("Delivery Status"),
                IgnorePointer(
                  ignoring: !form.canEdit("DeliveryStatus"),
                  child: Opacity(
                    opacity: form.canEdit("DeliveryStatus") ? 1 : 0.6,
                    child: FlexibleToggle(
                      label: "",
                      inactiveText: "Pending",
                      activeText: "Done",
                      initialValue: isDeliveryDone,
                      onChanged: (val) => setState(() => form.DeliveryStatus.text = val ? "Done" : "Pending"),
                    ),
                  ),
                ),
              ])),

            // ── Job Done ──────────────────────────────────────────────────
            if (form.canView("JobDone"))
              _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label("Final Job Done"),
                IgnorePointer(
                  ignoring: !form.canEdit("JobDone"),
                  child: Opacity(
                    opacity: form.canEdit("JobDone") ? 1 : 0.6,
                    child: FlexibleToggle(
                      label: "",
                      inactiveText: "NO",
                      activeText: "YES",
                      initialValue: isJobDone,
                      onChanged: (val) => setState(() => form.JobDone.text = val ? "YES" : "NO"),
                    ),
                  ),
                ),
              ])),

            const SizedBox(height: 20),

            // ── Save Button ───────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    final isCompleted = form.JobDone.text.trim().toUpperCase() == "YES";
                    await FirebaseFirestore.instance
                        .collection("jobs")
                        .doc(form.LpmAutoIncrement.text)
                        .set({
                      "delivery": {
                        "submitted": true,
                        "data": {
                          "DeliveryStatus": form.DeliveryStatus.text,
                          "JobDone": form.JobDone.text,
                          "ContactNumber": _contactNumber.text.trim(),
                          "WhatsappNumber": _whatsappNumber.text.trim(),
                          "ClientAddress": _clientAddress.text.trim(),
                          "ReceiverName": _receiverName.text.trim(),
                          "DeliveryAddress": _deliveryAddress.text.trim(),
                          "CourierName": _courierName.text.trim(),
                          "DeliveryRemark": _deliveryRemark.text.trim(),
                        },
                      },
                      "currentDepartment": isCompleted ? "Completed" : "Delivery",
                      "updatedAt": FieldValue.serverTimestamp(),
                    }, SetOptions(merge: true));

                    // --- BEGIN AUTOMATED DELIVERY EMAIL NOTIFICATION ---
                    try {
                      final isDone = form.DeliveryStatus.text.trim().toLowerCase() == "done";
                      if (isDone) {
                        final partyName = form.PartyName.text.trim();
                        if (partyName.isNotEmpty) {
                          final clientSnap = await FirebaseFirestore.instance
                              .collection('customers')
                              .where('Party Names', isEqualTo: partyName)
                              .limit(1)
                              .get();

                          if (clientSnap.docs.isNotEmpty) {
                            final clientEmail = (clientSnap.docs.first.data()['Email'] ?? '').toString().trim();
                            if (clientEmail.isNotEmpty) {
                              final jobRef = FirebaseFirestore.instance.collection("jobs").doc(form.LpmAutoIncrement.text);
                              final jobDoc = await jobRef.get();
                              final jobData = jobDoc.data() as Map<String, dynamic>? ?? {};

                              bool checkStatus(String dept, String statusKey) {
                                final status = (jobData[dept]?['data']?[statusKey] ?? "").toString().toLowerCase();
                                return status == "done";
                              }

                              final stepStatus = <String, bool>{
                                "Designing": checkStatus("designer", "DesigningStatus"),
                                "Laser Cutting": checkStatus("laserCutting", "LaserCuttingStatus"),
                                "Auto Bending": checkStatus("autoBending", "AutoBendingStatus"),
                                "Manual Bending": checkStatus("manualBending", "ManualBendingStatus"),
                                "Rubber": checkStatus("rubber", "RubberStatus"),
                                "Emboss": checkStatus("emboss", "EmbossStatus"),
                                "Delivered": true, // Force true since we are in Delivery Done
                              };

                              final doneBy = form.DeliveryCreatedBy.text.isNotEmpty
                                  ? form.DeliveryCreatedBy.text
                                  : "Delivery Team";
                              final timestamp = DateTime.now().toString().split('.').first;

                              // --- BEGIN DEPT-WISE EMAIL ATTACHMENTS FILTER ---
                              final List<Map<String, String>> attachments = [];
                              if (jobData['files'] != null) {
                                final filesMap = Map<String, dynamic>.from(jobData['files']);
                                final billPhoto = filesMap['DeliveryBillPhoto'] ?? filesMap['BillInvoice'];
                                if (billPhoto != null && billPhoto['viewUrl'] != null) {
                                  attachments.add({
                                    'url': billPhoto['viewUrl'].toString(),
                                    'label': 'Download Delivery Bill Photo',
                                  });
                                }
                                final productPhoto = filesMap['DeliveryProductImage'] ?? filesMap['ProductPhoto'];
                                if (productPhoto != null && productPhoto['viewUrl'] != null) {
                                  attachments.add({
                                    'url': productPhoto['viewUrl'].toString(),
                                    'label': 'Download Delivery Product Image',
                                  });
                                }
                              }
                              // --- END DEPT-WISE EMAIL ATTACHMENTS FILTER ---

                              final htmlBody = generateDepartmentEmailHtml(
                                departmentName: "Delivery",
                                partyName: partyName,
                                productName: form.ParticularJobName.text,
                                lpmNumber: form.LpmAutoIncrement.text,
                                actionDoneByLabel: "Done By",
                                actionDoneBy: doneBy,
                                actionTimestampLabel: "Done At",
                                actionTimestamp: timestamp,
                                stepStatus: stepStatus,
                                attachments: attachments,
                              );

                              final response = await http.post(
                                Uri.parse('https://senddispatchemail-3vvqs62r6q-uc.a.run.app'),
                                headers: {'Content-Type': 'application/json'},
                                body: jsonEncode({
                                  'to': clientEmail,
                                  'subject': 'Your Delivery is Ready! — ${form.LpmAutoIncrement.text}',
                                  'htmlBody': htmlBody,
                                }),
                              );

                              if (response.statusCode == 200) {
                                debugPrint('✅ sendDispatchEmail called successfully for Delivery ($clientEmail)');
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
                    // --- END AUTOMATED DELIVERY EMAIL NOTIFICATION ---

                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(isCompleted ? "✅ Job Fully Completed!" : "✅ Delivery Form Saved"), backgroundColor: Colors.green),
                    );
                    context.go('/dashboard');
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("❌ Error: $e"), backgroundColor: Colors.red),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF8D94B),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Save & Complete Job", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}