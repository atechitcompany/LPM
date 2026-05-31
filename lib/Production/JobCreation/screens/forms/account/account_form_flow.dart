import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:lightatech/Production/JobCreation/screens/forms/new_form_scope.dart';
import 'package:lightatech/FormComponents/FileUploadBox.dart';

//latest form. acc form 1 to 6 are useless
class AccountFormFlow extends StatefulWidget {
  const AccountFormFlow({super.key});

  @override
  State<AccountFormFlow> createState() => _AccountFormFlowState();
}

class _AccountFormFlowState extends State<AccountFormFlow> {
  bool _loading = true;
  bool _justSave = false;
  bool _loaded = false;

  String _partyName = "";
  String _jobName = "";
  String _lpm = "";

  final _extraEmailController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  @override
  void dispose() {
    _extraEmailController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final form = NewFormScope.of(context);
    _lpm = form.LpmAutoIncrement.text.trim();

    if (_lpm.isEmpty) {
      setState(() => _loading = false);
      return;
    }

    try {
      final snap = await FirebaseFirestore.instance.collection("jobs").doc(_lpm).get();
      if (snap.exists) {
        final designer = Map<String, dynamic>.from(snap.data()?["designer"]?["data"] ?? {});
        _partyName = designer["PartyName"] ?? "";
        _jobName = designer["ParticularJobName"] ?? "";
      }
    } catch (e) {
      debugPrint("❌ Error loading data: $e");
    }

    setState(() => _loading = false);
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    try {
      if (_justSave) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ Invoices saved"), backgroundColor: Colors.green),
          );
          context.go('/dashboard');
        }
      } else {
        final extraEmail = _extraEmailController.text.trim();

        String partyEmail = "";
        if (_partyName.isNotEmpty) {
          final snap = await FirebaseFirestore.instance
              .collection("customers")
              .where("Party Names", isEqualTo: _partyName)
              .limit(1)
              .get();
          if (snap.docs.isNotEmpty) {
            partyEmail = (snap.docs.first.data()["Email"] ?? "").toString().trim();
          }
        }

        final toEmail = extraEmail.isNotEmpty ? extraEmail : partyEmail;

        await FirebaseFirestore.instance.collection("jobs").doc(_lpm).set({
          "quotationSentTo": toEmail,
          "quotationSentAt": FieldValue.serverTimestamp(),
          "updatedAt": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("✅ Quotation sent to $toEmail"), backgroundColor: Colors.green),
          );
          context.go('/dashboard');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Error: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E2A3A),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
        title: const Text("Upload Quotations",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader("JOB DETAILS"),
            _infoCard([
              _infoRow("LPM Number", _lpm),
              _divider(),
              _infoRow("Party Name", _partyName),
              _divider(),
              _infoRow("Job Name", _jobName),
            ]),

            const SizedBox(height: 24),

            _sectionHeader("UPLOAD PROFORMA INVOICES"),
            const SizedBox(height: 4),

            _uploadLabel("Proforma Invoice 1"),
            FileUploadBox(
              jobId: _lpm,
              fieldName: 'ProformaInvoice1',
              onFileSelected: (file) => debugPrint("Invoice1: ${file.name}"),
            ),
            const SizedBox(height: 16),

            _uploadLabel("Proforma Invoice 2 (Optional)"),
            FileUploadBox(
              jobId: _lpm,
              fieldName: 'ProformaInvoice2',
              onFileSelected: (file) => debugPrint("Invoice2: ${file.name}"),
            ),
            const SizedBox(height: 16),

            _uploadLabel("Proforma Invoice 3 (Optional)"),
            FileUploadBox(
              jobId: _lpm,
              fieldName: 'ProformaInvoice3',
              onFileSelected: (file) => debugPrint("Invoice3: ${file.name}"),
            ),

            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 20),

            const Text("Quotation Action",
                style: TextStyle(fontSize: 13, color: Colors.black54)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Just Save Invoices",
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                  Switch(
                    value: _justSave,
                    onChanged: (v) => setState(() => _justSave = v),
                    activeColor: const Color(0xFF2979FF),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Divider(height: 1),
            const SizedBox(height: 20),

            if (!_justSave) ...[
              _sectionHeader("SEND TO ADDITIONAL EMAIL (OPTIONAL)"),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: TextField(
                  controller: _extraEmailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Send to this Mail To",
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                    prefixIcon: Icon(Icons.alternate_email, color: Colors.grey.shade400, size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _submit,
                  icon: const Icon(Icons.send, size: 18),
                  label: const Text("Send Quotation to Customer",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2979FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.save_alt, size: 18),
                label: const Text("Save Invoices",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E2A3A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(text,
        style: const TextStyle(
            fontSize: 11, fontWeight: FontWeight.w700,
            color: Color(0xFF2979FF), letterSpacing: 0.8)),
  );

  Widget _uploadLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
  );

  Widget _infoCard(List<Widget> children) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Column(children: children),
  );

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
      const SizedBox(height: 4),
      Text(value.isEmpty ? "—" : value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    ]),
  );

  Widget _divider() => Divider(height: 1, color: Colors.grey.shade100);
}