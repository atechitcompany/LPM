import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart'; // NEW IMPORT
import 'dart:typed_data';

import '../models/lead_model.dart';
import '../core/constants.dart';
import 'lead_form_screen.dart';
import 'payment_screen.dart';

class LeadDetailScreen extends StatefulWidget {
  final Lead lead;
  const LeadDetailScreen({super.key, required this.lead});
  @override
  State<LeadDetailScreen> createState() => _LeadDetailScreenState();
}

class _LeadDetailScreenState extends State<LeadDetailScreen> {
  late Lead lead;
  StreamSubscription<DocumentSnapshot>? _listener;

  // --- PERMISSIONS STATE ---
  String _userRole = 'Employee';
  List<dynamic> _visibleCols = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    lead = widget.lead;

    // Force Start Timer (Safety)
    Timer(const Duration(seconds: 2), () {
      if (mounted && _isLoading) setState(() => _isLoading = false);
    });

    _loadUserPermissions(); // Load Rules

    _listener = FirebaseFirestore.instance.collection('leads').doc(lead.id).snapshots().listen((snapshot) {
      if (snapshot.exists) {
        if(mounted) {
          setState(() {
            var data = snapshot.data() as Map<String, dynamic>;
            data['id'] = snapshot.id;
            lead = Lead.fromJson(data);
          });
        }
      }
    });
  }

  // --- LOAD PERMISSIONS ---
  Future<void> _loadUserPermissions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      _userRole = prefs.getString('userRole') ?? 'Employee';

      if (_userRole == 'Admin') {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      if (userId != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
        if (doc.exists) {
          final data = doc.data()!;
          if (mounted) {
            setState(() {
              _visibleCols = data['visibleColumns'] ?? [];
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- GATEKEEPER CHECK ---
  bool _canSee(String colName) {
    if (_userRole == 'Admin') return true;
    return _visibleCols.contains(colName);
  }

  @override
  void dispose() {
    _listener?.cancel();
    super.dispose();
  }

  // --- WHATSAPP TEMPLATES ---
  void _showWhatsAppTemplates() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Quick WhatsApp Message", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _templateTile("👋 Intro / Welcome", "Hello ${lead.leadName}, thank you for visiting A Tech Company. We look forward to working with you."),
              _templateTile("💰 Payment Reminder", "Hello ${lead.leadName}, this is a gentle reminder regarding your pending balance of Rs. ${lead.pendingAmount}. Please clear it at the earliest."),
              _templateTile("✅ Project Update", "Hello ${lead.leadName}, your project work is in progress. We will update you shortly."),
              _templateTile("📍 Send Address", "Hello, our office address is: A Tech IT Company, [Virar East]. Location: [Link]"),
            ],
          ),
        );
      },
    );
  }

  Widget _templateTile(String title, String message) {
    return ListTile(
      leading: const Icon(Icons.chat, color: Colors.green),
      title: Text(title),
      subtitle: Text(message, maxLines: 1, overflow: TextOverflow.ellipsis),
      onTap: () async {
        Navigator.pop(context);
        final phone = PhoneHelper.normalize(lead.whatsapp);
        if (phone.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No WhatsApp number found')));
          return;
        }
        final url = Uri.parse("https://wa.me/$phone?text=${Uri.encodeComponent(message)}");
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);
          _recordCallLocal('WhatsApp Template');
        }
      },
    );
  }

  Future<void> _openWhatsApp(String? phone) async {
    final uri = PhoneHelper.whatsappUri(phone);
    if (uri != null && await canLaunchUrl(uri)) {
      _recordCallLocal('WhatsApp');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openDialer(String? phone) async {
    final uri = PhoneHelper.telUri(phone);
    if (uri != null && await canLaunchUrl(uri)) {
      _recordCallLocal('Call');
      await launchUrl(uri);
    }
  }

  void _recordCallLocal(String via) async {
    final ts = DateTime.now();
    final tsPretty = '${ts.day.toString().padLeft(2, '0')}/${ts.month.toString().padLeft(2, '0')}/${ts.year}, ${_formatTime(ts)}';
    final updatedLogs = [{'ts': tsPretty, 'via': via}, ...lead.callLogs];
    setState(() { lead.callCount = lead.callCount + 1; lead.callLogs = updatedLogs; });
    await FirebaseFirestore.instance.collection('leads').doc(lead.id).update({'callCount': lead.callCount, 'callLogs': updatedLogs});
  }

  String _formatTime(DateTime d) {
    final h = d.hour == 0 || d.hour == 12 ? 12 : d.hour % 12;
    final min = d.minute.toString().padLeft(2, '0');
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    return '$h:$min $ampm';
  }

  void _editLead() async { await Navigator.of(context).push(MaterialPageRoute(builder: (_) => LeadFormScreen(initialLead: lead))); }

  void _deleteLead() async {
    final ok = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text('Delete Lead?'), content: const Text('This will permanently delete the customer profile. Continue?'), actions: [TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')), TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete', style: TextStyle(color: Colors.red)))]));
    if (ok == true) {
      await FirebaseFirestore.instance.collection('leads').doc(lead.id).delete();
      if(mounted) Navigator.of(context).pop();
    }
  }

  void _addPayment() async {
    final result = await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(builder: (_) => PaymentFormScreen(receiptNo: null, grandTotal: lead.finalAmount > 0 ? lead.finalAmount : lead.grandTotal, totalPaidSoFar: lead.totalPaid)),
    );

    if (result != null && result['action'] == 'add') {
      final amt = (result['amount'] as num?)?.toDouble() ?? 0.0;
      final paymentEntry = {
        'amount': amt, 'date': result['date'], 'remark': result['remark'], 'receiptNo': result['receiptNo'],
        'gstApplied': result['gstApplied'], 'gstAmount': result['gstAmount'], 'cgst': result['cgst'], 'sgst': result['sgst'],
        'generateBill': result['generateBill'], 'billNo': result['billNo'], 'billDate': result['billDate'],
      };
      final updatedPayments = [paymentEntry, ...lead.payments];
      final newTotalPaid = updatedPayments.fold(0.0, (p, e) => p + (e['amount'] as num).toDouble());
      final newPending = (lead.finalAmount - newTotalPaid).clamp(0.0, double.infinity);
      String newStatus = lead.leadStatus;
      if (newTotalPaid >= lead.finalAmount && lead.finalAmount > 0) newStatus = 'Paid';

      await FirebaseFirestore.instance.collection('leads').doc(lead.id).update({'payments': updatedPayments, 'totalPaid': newTotalPaid, 'pendingAmount': newPending, 'leadStatus': newStatus});
      if(mounted) Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReceiptPreviewScreen(lead: lead, payment: paymentEntry)));
    }
  }

  Future<void> _sharePaymentPdf(Map<String, dynamic> payment) async {
    try {
      final bytes = await generateReceiptPdf(lead, payment);
      await Printing.sharePdf(bytes: bytes, filename: '${payment['receiptNo'] ?? 'receipt'}.pdf');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to export PDF')));
    }
  }

  // --- HELPERS FOR UI ---
  Widget row(String title, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 120, child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 13))), Expanded(child: Text(value, style: const TextStyle(fontSize: 14)))]));
  }

  Widget _actionBtn(IconData icon, String label, VoidCallback onTap, {Color color = Colors.black}) {
    return InkWell(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.grey.shade300)), child: Row(children: [Icon(icon, size: 18, color: color), const SizedBox(width: 8), Text(label, style: TextStyle(fontWeight: FontWeight.w600, color: color))])));
  }

  void _copyToClipboard() {
    String details = "Name: ${lead.leadName}\nPhone: ${lead.whatsapp}";
    Clipboard.setData(ClipboardData(text: details));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied!')));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('Client Profile'),
          actions: [
            IconButton(icon: const Icon(Icons.copy_all), onPressed: _copyToClipboard),
            IconButton(icon: const Icon(Icons.edit), onPressed: _editLead),
            if (_userRole == 'Admin')
              IconButton(icon: const Icon(Icons.delete), onPressed: _deleteLead)
          ]
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.grey[50], padding: const EdgeInsets.all(20),
              child: Column(children: [
                CircleAvatar(radius: 35, backgroundColor: kPrimaryYellow, child: Text(avatarChar(lead.leadName), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black))),
                const SizedBox(height: 12),
                Text(lead.leadName ?? '(No name)', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                // Gatekeeper: Company
                if (_canSee('Company')) Text(lead.company ?? '', style: const TextStyle(color: Colors.grey, fontSize: 16)),
                const SizedBox(height: 16),

                // Gatekeeper: Actions (Hide if Phone is hidden)
                if (_canSee('Phone'))
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      _actionBtn(Icons.call, "Call", () => _openDialer(lead.whatsapp ?? lead.contact2)),
                      const SizedBox(width: 12),
                      _actionBtn(Icons.chat, "WhatsApp", () => _openWhatsApp(lead.whatsapp)),
                      const SizedBox(width: 12),
                      _actionBtn(Icons.bolt, "Templates", _showWhatsAppTemplates, color: Colors.orange),
                    ]),
                  )
              ]),
            ),
            const SizedBox(height: 10),

            // Gatekeeper: Financials (Hide if Amount hidden)
            if (_canSee('Amount'))
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(children: [
                  SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: _addPayment, style: ElevatedButton.styleFrom(backgroundColor: kGreenColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)), icon: const Icon(Icons.add_card), label: const Text('ADD NEW PAYMENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
                    child: ExpansionTile(
                      initiallyExpanded: false, shape: const Border(), title: const Text("Payment History", style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("Total Paid: ₹${lead.totalPaid.toStringAsFixed(0)} | Pending: ₹${lead.pendingAmount.toStringAsFixed(0)}"),
                      children: [
                        if(lead.payments.isEmpty) const Padding(padding: EdgeInsets.all(16.0), child: Text("No payments yet.")),
                        ...lead.payments.asMap().entries.map((entry) {
                          final p = entry.value;

                          return ListTile(dense: true, leading: const Icon(Icons.check_circle, color: Colors.green, size: 20), title: Text('₹ ${(p['amount'] as num).toDouble().toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Text('${p['date']} • RCPT:${p['receiptNo']}'), trailing: IconButton(icon: const Icon(Icons.picture_as_pdf, color: Colors.grey), onPressed: () => _sharePaymentPdf(p)));
                        }).toList(),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ]),
              ),
            const Divider(thickness: 4, color: Color(0xFFF5F5F5)),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("Client Details", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                // Gatekeeper applied to Rows
                if (_canSee('Status')) row('Status', lead.leadStatus),
                if (_canSee('Phone')) row('Phone', lead.whatsapp),
                if (_canSee('Phone')) row('Alt Phone', lead.contact2),
                if (_canSee('Address')) row('Address', lead.address),
                if (_canSee('Client Type')) row('Type', lead.leadType),
                row('Source', lead.leadSource),
                row('Profession', lead.profession),
                if (_canSee('Remark')) row('Remark', lead.remark),

                const Divider(height: 30),
                const Text("Stats", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Profile Created: ${lead.dateTime}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text('Total Interaction Calls: ${lead.callCount}', style: const TextStyle(color: Colors.grey, fontSize: 12)),

                // --- AUDIT TRAIL (NEW ADDITION) ---
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("ENTRY LOGS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("First Created:", style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text("${lead.createdBy ?? 'Unknown'} \n(${lead.createdOn ?? '-'})", textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      if (lead.editedBy != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Last Edited:", style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text("${lead.editedBy} \n(${lead.editedOn})", textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue)),
                          ],
                        ),
                      ]
                    ],
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}