import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';

class AccountQuotationDetailScreen extends StatefulWidget {
  final String docId;
  const AccountQuotationDetailScreen({super.key, required this.docId});

  @override
  State<AccountQuotationDetailScreen> createState() => _AccountQuotationDetailScreenState();
}

class _AccountQuotationDetailScreenState extends State<AccountQuotationDetailScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  Future<void> _fetch() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('quotations')
          .doc(widget.docId)
          .get();

      // Files are saved in jobs collection by FileUploadBox
      final jobDoc = await FirebaseFirestore.instance
          .collection('jobs')
          .doc(widget.docId)
          .get();

      if (mounted) setState(() {
        _data = doc.data();
        if (jobDoc.exists) {
          _data!['files'] = jobDoc.data()?['files'];
        }
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1E2A3A),
        foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: const Text("Quotation Detail", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _data == null
          ? const Center(child: Text('Not found'))
          : SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader("QUOTE DETAILS"),
            _infoCard([
              _infoRow("Quote Number", _data!['quoteNumber'] ?? widget.docId),
              _divider(),
              _infoRow("Party Name", _data!['PartyName'] ?? ''),
              _divider(),
              _infoRow("Job Name", _data!['ParticularJobName'] ?? ''),
              _divider(),
              _infoRow("Sent To", _data!['quotationSentTo'] ?? ''),
            ]),

            const SizedBox(height: 24),

            _sectionHeader("UPLOADED INVOICES"),
            const SizedBox(height: 8),
            _buildFiles(),
          ],
        ),
      ),
    );
  }

  Widget _buildFiles() {
    final files = _data!['files'] as Map<String, dynamic>?;
    if (files == null || files.isEmpty) {
      return Text("No files uploaded", style: TextStyle(color: Colors.grey.shade400));
    }
    return Column(
      children: files.entries.map((entry) {
        final file = entry.value as Map<String, dynamic>;
        final fileName = file['fileName'] ?? entry.key;
        final viewUrl = file['viewUrl'] ?? '';
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: const Icon(Icons.insert_drive_file, color: Color(0xFF2979FF)),
            title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            subtitle: Text(fileName, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            trailing: viewUrl.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.open_in_new, color: Color(0xFF2979FF)),
              onPressed: () {/* open url */},
            )
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _sectionHeader(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF2979FF), letterSpacing: 0.8)),
  );

  Widget _infoCard(List<Widget> children) => Container(
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
    child: Column(children: children),
  );

  Widget _infoRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
      const SizedBox(height: 4),
      Text(value.isEmpty ? "—" : value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
    ]),
  );

  Widget _divider() => Divider(height: 1, color: Colors.grey.shade100);
}