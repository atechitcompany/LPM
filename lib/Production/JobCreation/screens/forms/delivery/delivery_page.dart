import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lightatech/FormComponents/TextInput.dart';
import 'package:lightatech/FormComponents/FlexibleToggle.dart';
import 'package:lightatech/FormComponents/FileUploadBox.dart';
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
    final lpm = form.LpmAutoIncrement.text;
    if (lpm.isEmpty) { setState(() => loading = false); return; }

    try {
      final snap = await FirebaseFirestore.instance.collection("jobs").doc(lpm).get();
      if (!snap.exists) { setState(() => loading = false); return; }

      final data = snap.data()!;
      final designer = Map<String, dynamic>.from(data["designer"]?["data"] ?? {});
      final autoBending = Map<String, dynamic>.from(data["autoBending"]?["data"] ?? {});
      final laserCutting = Map<String, dynamic>.from(data["laserCutting"]?["data"] ?? {});
      final account = Map<String, dynamic>.from(data["account"]?["data"] ?? {});
      final delivery = Map<String, dynamic>.from(data["delivery"]?["data"] ?? {});

      form.PartyName.text = designer["PartyName"] ?? "";
      form.ParticularJobName.text = designer["ParticularJobName"] ?? designer["particularJobName"] ?? "";
      form.LpmAutoIncrement.text = lpm;
      form.DeliveryAt.text = designer["DeliveryAt"] ?? account["DeliveryAt"] ?? "";
      form.Remark.text = designer["Remark"] ?? account["Remark"] ?? "";
      form.AutoBendingCreatedBy.text = autoBending["AutoBendingCreatedBy"] ?? "";
      form.LaserCuttingCreatedBy.text = laserCutting["LaserCuttingCreatedBy"] ?? "";
      form.AccountsCreatedBy.text = account["AccountsCreatedBy"] ?? "";

      form.DeliveryStatus.text = delivery["DeliveryStatus"] ?? "Pending";
      form.JobDone.text = delivery["JobDone"] ?? "NO";

      setState(() {
        _contactNumber.text = delivery["ContactNumber"] ?? "";
        _whatsappNumber.text = delivery["WhatsappNumber"] ?? "";
        _clientAddress.text = delivery["ClientAddress"] ?? "";
        _receiverName.text = delivery["ReceiverName"] ?? "";
        _deliveryAddress.text = delivery["DeliveryAddress"] ?? "";
        _courierName.text = delivery["CourierName"] ?? "";
        _deliveryRemark.text = delivery["DeliveryRemark"] ?? "";
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

            if (form.canView("AutoBendingCreatedBy"))
              _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label("Auto Bending Created By"),
                TextInput(label: "", controller: form.AutoBendingCreatedBy, readOnly: true, hint: ""),
              ])),

            if (form.canView("LaserCuttingCreatedBy"))
              _fieldCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _label("Laser Cutting Created By"),
                TextInput(label: "", controller: form.LaserCuttingCreatedBy, readOnly: true, hint: ""),
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