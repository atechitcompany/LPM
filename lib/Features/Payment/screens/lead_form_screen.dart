import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // DATE FORMATTING KE LIYE

import '../models/lead_model.dart';
import '../core/constants.dart';
import '../core/notification_helper.dart';

class LeadFormScreen extends StatefulWidget {
  final Lead? initialLead;
  const LeadFormScreen({super.key, this.initialLead});
  @override
  State<LeadFormScreen> createState() => _LeadFormScreenState();
}

class _LeadFormScreenState extends State<LeadFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dateTimeCtrl = TextEditingController();

  // --- PERMISSION STATE ---
  bool _isLoadingPerms = true;
  String _userRole = 'Employee';
  List<dynamic> _visibleCols = [];
  List<dynamic> _editableCols = [];

  // Controllers
  String? _company = sampleCompanies.first;
  String? _address = sampleAddresses.first;
  String? _source = sampleLeadSources.first;
  final _companyOtherCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _nameOnReceiptCtrl = TextEditingController();
  final _professionCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _contact2Ctrl = TextEditingController();
  final _addressOtherCtrl = TextEditingController();
  final _sourceOtherCtrl = TextEditingController();
  final _remarkCtrl = TextEditingController();
  final _grandTotalCtrl = TextEditingController(text: '0');
  final _couponCtrl = TextEditingController();
  final _finalAmountCtrl = TextEditingController(text: '0.00');
  String _type = 'Client';
  String _status = 'Hot';

  @override
  void initState() {
    super.initState();
    _loadUserPermissions();
    _initFormData();
  }

  // --- 1. LOAD PERMISSIONS ---
  Future<void> _loadUserPermissions() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    _userRole = prefs.getString('userRole') ?? 'Employee';

    if (_userRole == 'Admin') {
      setState(() => _isLoadingPerms = false);
      return;
    }

    if (userId != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _visibleCols = data['visibleColumns'] ?? [];
          _editableCols = data['editableColumns'] ?? [];
          _isLoadingPerms = false;
        });
      }
    }
  }

  void _initFormData() {
    if (widget.initialLead != null) {
      final L = widget.initialLead!;
      _dateTimeCtrl.text = L.dateTime;
      _company = L.company ?? sampleCompanies.first;
      if (!sampleCompanies.contains(_company)) {
        _company = 'Other';
        _companyOtherCtrl.text = L.company ?? '';
      }
      _nameCtrl.text = L.leadName ?? '';
      _nameOnReceiptCtrl.text = L.nameOnReceipt ?? '';
      _professionCtrl.text = L.profession ?? '';
      _whatsappCtrl.text = L.whatsapp ?? '';
      _contact2Ctrl.text = L.contact2 ?? '';
      _address = L.address ?? sampleAddresses.first;
      if (!sampleAddresses.contains(_address)) {
        _address = 'Other';
        _addressOtherCtrl.text = L.address ?? '';
      }
      _type = L.leadType;
      _status = L.leadStatus;
      _source = L.leadSource ?? sampleLeadSources.first;
      if (!sampleLeadSources.contains(_source)) {
        _source = 'Other';
        _sourceOtherCtrl.text = L.leadSource ?? '';
      }
      _remarkCtrl.text = L.remark ?? '';
      _grandTotalCtrl.text = L.grandTotal.toStringAsFixed(0);
      _finalAmountCtrl.text = L.finalAmount.toStringAsFixed(0);
    } else {
      _dateTimeCtrl.text = _prettyNow();
      _source = sampleLeadSources.first;
      _recalcFinal();
    }
  }

  String _prettyNow() {
    final d = DateTime.now();
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}, ${_formatTime(d)}';
  }

  String _formatTime(DateTime d) {
    final h = d.hour == 0 || d.hour == 12 ? 12 : d.hour % 12;
    final min = d.minute.toString().padLeft(2, '0');
    final ampm = d.hour >= 12 ? 'PM' : 'AM';
    return '$h:$min $ampm';
  }

  void _pickDateTime() async {
    final now = DateTime.now();
    final d = await showDatePicker(context: context, initialDate: now, firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (d == null) return;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(now));
    final dt = DateTime(d.year, d.month, d.day, t?.hour ?? 0, t?.minute ?? 0);
    _dateTimeCtrl.text = '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}, ${_formatTime(dt)}';
    setState(() {});
  }

  void _recalcFinal() {
    final base = double.tryParse(_grandTotalCtrl.text.replaceAll(',', '')) ?? 0.0;
    var finalAmt = base;
    final coupon = _couponCtrl.text.trim();
    if (coupon.endsWith('%')) {
      final perc = double.tryParse(coupon.replaceAll('%', '')) ?? 0.0;
      finalAmt = finalAmt * (1 - perc / 100);
    } else if (coupon.isNotEmpty) {
      final disc = double.tryParse(coupon) ?? 0.0;
      finalAmt = (finalAmt - disc).clamp(0.0, double.infinity);
    }
    _finalAmountCtrl.text = finalAmt.toStringAsFixed(0);
    setState(() {});
  }

  // --- SAVE WITH AUDIT & NOTIFICATION LOGIC ---
  void _onSave() async {
    if (!(_formKey.currentState?.validate() ?? true)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fix errors')));
      return;
    }

    try {
      final id = widget.initialLead?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
      final resolvedCompany = _company == 'Other' ? _companyOtherCtrl.text : _company;
      final resolvedAddress = _address == 'Other' ? _addressOtherCtrl.text : _address;
      final resolvedSource = _source == 'Other' ? _sourceOtherCtrl.text : _source;
      final grandTotal = double.tryParse(_grandTotalCtrl.text) ?? 0.0;
      final finalAmt = double.tryParse(_finalAmountCtrl.text) ?? grandTotal;

      // 1. GET USER INFO
      final prefs = await SharedPreferences.getInstance();
      final currentUser = prefs.getString('userName') ?? 'Admin';
      final nowStr = DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now());

      // 2. AUDIT TRAIL LOGIC
      String? creatorName = widget.initialLead?.createdBy;
      String? createdTime = widget.initialLead?.createdOn;
      String? editorName = widget.initialLead?.editedBy;
      String? editedTime = widget.initialLead?.editedOn;

      if (widget.initialLead == null) {
        // Create Mode
        creatorName = currentUser;
        createdTime = nowStr;
      } else {
        // Edit Mode
        editorName = currentUser;
        editedTime = nowStr;
      }

      final lead = Lead(
        id: id,
        dateTime: _dateTimeCtrl.text,
        company: resolvedCompany,
        leadName: _nameCtrl.text.isEmpty ? null : _nameCtrl.text,
        nameOnReceipt: _nameOnReceiptCtrl.text.isEmpty ? null : _nameOnReceiptCtrl.text,
        profession: _professionCtrl.text.isEmpty ? null : _professionCtrl.text,
        whatsapp: _whatsappCtrl.text.isEmpty ? null : _whatsappCtrl.text,
        contact2: _contact2Ctrl.text.isEmpty ? null : _contact2Ctrl.text,
        address: resolvedAddress,
        leadType: _type,
        leadStatus: _status,
        leadSource: resolvedSource,
        remark: _remarkCtrl.text.isEmpty ? null : _remarkCtrl.text,
        grandTotal: grandTotal,
        finalAmount: finalAmt,
        totalPaid: widget.initialLead?.totalPaid ?? 0.0,
        pendingAmount: (finalAmt - (widget.initialLead?.totalPaid ?? 0.0)).clamp(0.0, double.infinity),
        payments: widget.initialLead?.payments ?? [],
        callLogs: widget.initialLead?.callLogs ?? [],
        callCount: widget.initialLead?.callCount ?? 0,

        // SAVE AUDIT FIELDS
        createdBy: creatorName,
        createdOn: createdTime,
        editedBy: editorName,
        editedOn: editedTime,
      );

      // SAVE TO FIRESTORE
      await FirebaseFirestore.instance.collection('leads').doc(id).set(lead.toJson());

      // --- NOTIFY ADMIN (Only on New Entry) ---
      if (widget.initialLead == null) {
        NotificationHelper.sendAdminNotification(
            title: "New Client Added",
            message: "$currentUser added a new client: ${_nameCtrl.text}",
            type: "New Lead"
        );
      }

      if (mounted) {
        Navigator.of(context).pop(lead);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved!'), backgroundColor: Colors.green, duration: Duration(milliseconds: 800)));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Widget _buildSmartField(String colName, Widget child, {bool isDropdown = false}) {
    if (_userRole == 'Admin') return child;
    if (!_visibleCols.contains(colName)) return const SizedBox.shrink();
    if (!_editableCols.contains(colName)) {
      return AbsorbPointer(absorbing: true, child: Opacity(opacity: 0.6, child: child));
    }
    return child;
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.normal),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: kPrimaryYellow, width: 1.2)),
    );
  }

  Widget _buildLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 20),
      child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingPerms) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      appBar: AppBar(
        title: Text(widget.initialLead == null ? 'Add Client' : 'Edit Client'),
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: false,
        titleTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          TextButton(onPressed: _onSave, child: const Text("Save", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Date *'),
              TextFormField(controller: _dateTimeCtrl, readOnly: true, decoration: _inputDeco('Select Date').copyWith(suffixIcon: IconButton(icon: const Icon(Icons.calendar_today_outlined, size: 20), onPressed: _pickDateTime))),

              _buildLabel('Company'),
              DropdownButtonFormField<String>(
                value: _company, decoration: _inputDeco('Select Company'), icon: const Icon(Icons.keyboard_arrow_down),
                items: sampleCompanies.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setState(() => _company = v),
              ),
              if (_company == 'Other') ...[const SizedBox(height: 10), TextFormField(controller: _companyOtherCtrl, decoration: _inputDeco('Enter company name'))],

              _buildLabel('Party Name (Client Name) *'),
              TextFormField(controller: _nameCtrl, decoration: _inputDeco('Field text goes here'), validator: (v) => (v == null || v.isEmpty) ? 'Name is required' : null),

              _buildSmartField('Phone', Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('WhatsApp Number'), TextFormField(controller: _whatsappCtrl, keyboardType: TextInputType.phone, decoration: _inputDeco('+91 ...'))])),

              _buildSmartField('Address', Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Address'), DropdownButtonFormField<String>(value: _address, decoration: _inputDeco('Select Address'), icon: const Icon(Icons.keyboard_arrow_down), items: sampleAddresses.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (v) => setState(() => _address = v)), if (_address == 'Other') ...[const SizedBox(height: 10), TextFormField(controller: _addressOtherCtrl, decoration: _inputDeco('Enter full address'))]])),

              _buildSmartField('Amount', Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Listing Price (Grand Total)'), TextFormField(controller: _grandTotalCtrl, keyboardType: TextInputType.number, decoration: _inputDeco('0'), onChanged: (_) => _recalcFinal()), _buildLabel('Discount (Amount or %)'), TextFormField(controller: _couponCtrl, decoration: _inputDeco('e.g. 500 or 10%'), onChanged: (_) => _recalcFinal()), _buildLabel('Final Amount (Selling Price)'), TextFormField(controller: _finalAmountCtrl, readOnly: true, decoration: _inputDeco('0.00').copyWith(fillColor: Colors.grey.shade50))])),

              _buildSmartField('Status', Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Priority / Status'), Wrap(spacing: 8, runSpacing: 8, children: ['Hot', 'Warm', 'Cold', 'Book', 'Paid'].map((status) => IntrinsicWidth(child: GestureDetector(onTap: () => setState(() => _status = status), child: Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), decoration: BoxDecoration(color: _status == status ? Colors.black : Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: _status == status ? Colors.black : Colors.grey.shade300)), child: Text(status, style: TextStyle(color: _status == status ? Colors.white : Colors.black, fontWeight: FontWeight.w600)))))).toList())])),

              _buildSmartField('Remark', Column(crossAxisAlignment: CrossAxisAlignment.start, children: [_buildLabel('Remark'), TextFormField(controller: _remarkCtrl, maxLines: 3, decoration: _inputDeco('Any specific requirement...'))])),

              const SizedBox(height: 30),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _onSave, style: ElevatedButton.styleFrom(backgroundColor: kPrimaryYellow, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0), child: Text(widget.initialLead == null ? 'CREATE CLIENT' : 'UPDATE CLIENT', style: const TextStyle(fontWeight: FontWeight.bold)))),
              const SizedBox(height: 20),

              // --- AUDIT TRAIL DISPLAY ---
              if (widget.initialLead != null) ...[
                const Divider(),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("ENTRY DETAILS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Created By:", style: TextStyle(fontSize: 12, color: Colors.grey)),
                          Text("${widget.initialLead?.createdBy ?? 'Unknown'} \n(${widget.initialLead?.createdOn ?? '-'})", textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      if (widget.initialLead?.editedBy != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Last Edited By:", style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text("${widget.initialLead?.editedBy} \n(${widget.initialLead?.editedOn})", textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue)),
                          ],
                        ),
                      ]
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        ),
      ),
    );
  }
}